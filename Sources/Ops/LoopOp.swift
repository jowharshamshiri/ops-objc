import Foundation

/// Loop operation that executes a batch of operations repeatedly until a limit is reached.
public final class LoopOp<T: Sendable>: Sendable {
    private let counterVar: String
    private let limit: Int
    private let ops: [AnyOp<T>]
    private let loopId: String
    private let continueVar: String
    private let breakVar: String
    private let continueOnError: Bool

    public init(counterVar: String, limit: Int, ops: [AnyOp<T>], continueOnError: Bool = false) {
        let id = UUID().uuidString
        self.counterVar = counterVar
        self.limit = limit
        self.ops = ops
        self.loopId = id
        self.continueVar = "__continue_loop_\(id)"
        self.breakVar = "__break_loop_\(id)"
        self.continueOnError = continueOnError
    }

    public func addOp(_ op: AnyOp<T>) -> LoopOp<T> {
        var newOps = ops
        newOps.append(op)
        return LoopOp(counterVar: counterVar, limit: limit, ops: newOps, continueOnError: continueOnError)
    }

    private func rollbackIterationOps(_ succeeded: [AnyOp<T>], dry: DryContext, wet: WetContext) async {
        for op in succeeded.reversed() {
            try? await op.rollback(dry: dry, wet: wet)
        }
    }

    public func perform(dry: DryContext, wet: WetContext) async throws -> [T] {
        var results: [T] = []
        var counter = dry.get(Int.self, for: counterVar) ?? 0

        if !dry.contains(counterVar) {
            dry.insert(counter, for: counterVar)
        }

        dry.insert(loopId, for: "__current_loop_id")

        while counter < limit {
            if dry.isAborted {
                let reason = dry.abortReason ?? "Loop operation aborted"
                throw OpError.aborted(reason)
            }

            dry.insert(false, for: continueVar)
            dry.insert(false, for: breakVar)

            var iterationSucceeded: [AnyOp<T>] = []

            for op in ops {
                if dry.isAborted {
                    await rollbackIterationOps(iterationSucceeded, dry: dry, wet: wet)
                    let reason = dry.abortReason ?? "Loop operation aborted"
                    throw OpError.aborted(reason)
                }

                do {
                    let result = try await op.perform(dry: dry, wet: wet)
                    results.append(result)
                    iterationSucceeded.append(op)

                    if dry.get(Bool.self, for: continueVar) == true {
                        dry.insert(false, for: continueVar)
                        break // break out of ops loop, continue to next iteration
                    }

                    if dry.get(Bool.self, for: breakVar) == true {
                        dry.insert(false, for: breakVar)
                        return results // break out of entire loop
                    }
                } catch OpError.aborted(let reason) {
                    await rollbackIterationOps(iterationSucceeded, dry: dry, wet: wet)
                    throw OpError.aborted(reason)
                } catch OpError._loopContinue {
                    // continue_loop: set flag and break out of ops loop
                    dry.insert(true, for: continueVar)
                    dry.insert(false, for: continueVar) // immediately cleared as processed
                    break
                } catch OpError._loopBreak {
                    // break_loop: exit entire loop
                    return results
                } catch let err as OpError {
                    if continueOnError {
                        await rollbackIterationOps(iterationSucceeded, dry: dry, wet: wet)
                        break // continue to next iteration
                    } else {
                        await rollbackIterationOps(iterationSucceeded, dry: dry, wet: wet)
                        throw err
                    }
                } catch {
                    if continueOnError {
                        await rollbackIterationOps(iterationSucceeded, dry: dry, wet: wet)
                        break
                    } else {
                        await rollbackIterationOps(iterationSucceeded, dry: dry, wet: wet)
                        throw OpError.executionFailed(error.localizedDescription)
                    }
                }
            }

            counter += 1
            dry.insert(counter, for: counterVar)
        }

        return results
    }

    public func metadata() -> OpMetadata {
        let desc = continueOnError
            ? "Loop \(limit) times over \(ops.count) ops (continue on error)"
            : "Loop \(limit) times over \(ops.count) ops"
        return OpMetadata.builder("LoopOp")
            .description(desc)
            .build()
    }
}
