import Foundation

/// Executes multiple ops in sequence, with automatic LIFO rollback on failure.
public final class BatchOp<T: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var _ops: [AnyOp<T>]
    private let continueOnError: Bool

    public init(ops: [AnyOp<T>], continueOnError: Bool = false) {
        self._ops = ops
        self.continueOnError = continueOnError
    }

    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return _ops.count
    }

    public var isEmpty: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _ops.isEmpty
    }

    /// Dynamically add an op to the batch.
    public func addOp(_ op: some Op<T>) {
        lock.lock()
        defer { lock.unlock() }
        _ops.append(AnyOp(op))
    }

    private func currentOps() -> [AnyOp<T>] {
        lock.lock()
        defer { lock.unlock() }
        return _ops
    }

    private func rollbackSucceededOps(_ succeeded: [AnyOp<T>], dry: DryContext, wet: WetContext) async {
        for op in succeeded.reversed() {
            do {
                try await op.rollback(dry: dry, wet: wet)
            } catch {
                // Log and continue
            }
        }
    }

    public func perform(dry: DryContext, wet: WetContext) async throws -> [T] {
        let ops = currentOps()
        var results: [T] = []
        results.reserveCapacity(ops.count)
        var succeeded: [AnyOp<T>] = []
        var errors: [(Int, OpError)] = []

        for (index, op) in ops.enumerated() {
            if dry.isAborted {
                await rollbackSucceededOps(succeeded, dry: dry, wet: wet)
                let reason = dry.abortReason ?? "Batch operation aborted"
                throw OpError.aborted(reason)
            }

            do {
                let result = try await op.perform(dry: dry, wet: wet)
                results.append(result)
                succeeded.append(op)
            } catch OpError.aborted(let reason) {
                await rollbackSucceededOps(succeeded, dry: dry, wet: wet)
                throw OpError.aborted(reason)
            } catch let err as OpError {
                if continueOnError {
                    errors.append((index, err))
                } else {
                    await rollbackSucceededOps(succeeded, dry: dry, wet: wet)
                    throw OpError.batchFailed("Op \(index)-\(op.metadata().name) failed: \(err.description)")
                }
            } catch {
                let opErr = OpError.other(error as! any Error & Sendable)
                if continueOnError {
                    errors.append((index, opErr))
                } else {
                    await rollbackSucceededOps(succeeded, dry: dry, wet: wet)
                    throw OpError.batchFailed("Op \(index)-\(op.metadata().name) failed: \(error)")
                }
            }
        }

        return results
    }

    public func metadata() -> OpMetadata {
        BatchMetadataBuilder(ops: currentOps()).build()
    }

    public func rollback(dry: DryContext, wet: WetContext) async throws {
        // Default no-op rollback for batch
    }
}

// MARK: - Op conformance

extension BatchOp: Op {
    public typealias Output = [T]
}
