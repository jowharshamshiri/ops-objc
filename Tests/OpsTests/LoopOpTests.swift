import XCTest
@testable import Ops

final class LoopOpTests: XCTestCase {

    struct TestOp: Op {
        typealias Output = Int
        let value: Int
        func perform(dry: DryContext, wet: WetContext) async throws -> Int { value }
        func metadata() -> OpMetadata { OpMetadata.builder("TestOp").build() }
    }

    struct CounterOp: Op {
        typealias Output = Int
        func perform(dry: DryContext, wet: WetContext) async throws -> Int {
            dry.get(Int.self, for: "loop_counter") ?? 0
        }
        func metadata() -> OpMetadata { OpMetadata.builder("CounterOp").build() }
    }

    // TEST067: Run a LoopOp for 3 iterations with 2 ops each and verify all 6 results in order
    func test_067_loop_op_basic() async throws {
        let dry = DryContext(); let wet = WetContext()
        let ops = [AnyOp(TestOp(value: 10)), AnyOp(TestOp(value: 20))]
        let loopOp = LoopOp(counterVar: "loop_counter", limit: 3, ops: ops)
        let results = try await loopOp.perform(dry: dry, wet: wet)
        XCTAssertEqual(results.count, 6)
        XCTAssertEqual(results, [10, 20, 10, 20, 10, 20])
    }

    // TEST068: Run a LoopOp where each op reads the loop counter and verify values are 0, 1, 2
    func test_068_loop_op_with_counter_access() async throws {
        let dry = DryContext(); let wet = WetContext()
        let ops = [AnyOp(CounterOp())]
        let loopOp = LoopOp(counterVar: "loop_counter", limit: 3, ops: ops)
        let results = try await loopOp.perform(dry: dry, wet: wet)
        XCTAssertEqual(results, [0, 1, 2])
    }

    // TEST069: Start a LoopOp with a pre-initialized counter and verify it only executes remaining iterations
    func test_069_loop_op_existing_counter() async throws {
        let dry = DryContext().with(value: 2, for: "my_counter")
        let wet = WetContext()
        let ops = [AnyOp(TestOp(value: 42))]
        let loopOp = LoopOp(counterVar: "my_counter", limit: 4, ops: ops)
        let results = try await loopOp.perform(dry: dry, wet: wet)
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results, [42, 42])
    }

    // TEST070: Run a LoopOp with a zero iteration limit and verify no ops are executed
    func test_070_loop_op_zero_limit() async throws {
        let dry = DryContext(); let wet = WetContext()
        let ops = [AnyOp(TestOp(value: 99))]
        let loopOp = LoopOp(counterVar: "counter", limit: 0, ops: ops)
        let results = try await loopOp.perform(dry: dry, wet: wet)
        XCTAssertEqual(results.count, 0)
    }

    // TEST071: Build a LoopOp with addOp chaining and verify all added ops run across all iterations
    func test_071_loop_op_builder_pattern() async throws {
        let dry = DryContext(); let wet = WetContext()
        let loopOp = LoopOp(counterVar: "builder_counter", limit: 2, ops: [])
            .addOp(AnyOp(TestOp(value: 1)))
            .addOp(AnyOp(TestOp(value: 2)))
        let results = try await loopOp.perform(dry: dry, wet: wet)
        XCTAssertEqual(results.count, 4)
        XCTAssertEqual(results, [1, 2, 1, 2])
    }

    // TEST072: Run a LoopOp where the third op fails and verify succeeded ops are rolled back in reverse order
    func test_072_loop_op_rollback_on_iteration_failure() async {
        final class Log: @unchecked Sendable { var performed: [UInt32] = []; var rolledBack: [UInt32] = [] }
        let log = Log()

        struct RollbackOp: Op {
            typealias Output = UInt32
            let id: UInt32
            let shouldFail: Bool
            let log: Log
            func perform(dry: DryContext, wet: WetContext) async throws -> UInt32 {
                log.performed.append(id)
                if shouldFail { throw OpError.executionFailed("Op \(id) failed") }
                return id
            }
            func rollback(dry: DryContext, wet: WetContext) async throws { log.rolledBack.append(id) }
            func metadata() -> OpMetadata { OpMetadata.builder("RollbackOp\(id)").build() }
        }

        let ops = [
            AnyOp(RollbackOp(id: 1, shouldFail: false, log: log)),
            AnyOp(RollbackOp(id: 2, shouldFail: false, log: log)),
            AnyOp(RollbackOp(id: 3, shouldFail: true, log: log)),
        ]
        let loopOp = LoopOp(counterVar: "test_counter", limit: 2, ops: ops)
        let dry = DryContext(); let wet = WetContext()
        _ = try? await loopOp.perform(dry: dry, wet: wet)
        XCTAssertEqual(log.performed, [1, 2, 3])
        XCTAssertEqual(log.rolledBack, [2, 1])
    }

    // TEST073: Run a LoopOp where the last op fails and verify rollback occurs in LIFO order within the iteration
    func test_073_loop_op_rollback_order_within_iteration() async {
        final class Order: @unchecked Sendable { var order: [UInt32] = [] }
        let order = Order()

        struct TrackOp: Op {
            typealias Output = UInt32
            let id: UInt32
            let order: Order
            func perform(dry: DryContext, wet: WetContext) async throws -> UInt32 { id }
            func rollback(dry: DryContext, wet: WetContext) async throws { order.order.append(id) }
            func metadata() -> OpMetadata { OpMetadata.builder("TrackOp\(id)").build() }
        }
        struct FailOp: Op {
            typealias Output = UInt32
            func perform(dry: DryContext, wet: WetContext) async throws -> UInt32 {
                throw OpError.executionFailed("Intentional failure")
            }
            func metadata() -> OpMetadata { OpMetadata.builder("FailOp").build() }
        }

        let ops = [
            AnyOp(TrackOp(id: 1, order: order)),
            AnyOp(TrackOp(id: 2, order: order)),
            AnyOp(TrackOp(id: 3, order: order)),
            AnyOp(FailOp()),
        ]
        let loopOp = LoopOp(counterVar: "test_counter", limit: 1, ops: ops)
        let dry = DryContext(); let wet = WetContext()
        _ = try? await loopOp.perform(dry: dry, wet: wet)
        XCTAssertEqual(order.order, [3, 2, 1])
    }

    // TEST076: Run a LoopOp configured to continue on error and verify subsequent iterations still execute
    func test_076_loop_op_continue_on_error() async throws {
        final class Log: @unchecked Sendable { var performed: [(UInt32, Int)] = []; var rolledBack: [(UInt32, Int)] = [] }
        let log = Log()

        struct ContinueOp: Op {
            typealias Output = UInt32
            let id: UInt32
            let failOnIteration: Int?
            let log: Log
            func perform(dry: DryContext, wet: WetContext) async throws -> UInt32 {
                let counter = dry.get(Int.self, for: "test_counter") ?? 0
                log.performed.append((id, counter))
                if let fail = failOnIteration, counter == fail {
                    throw OpError.executionFailed("Op \(id) failed on iteration \(counter)")
                }
                return id
            }
            func rollback(dry: DryContext, wet: WetContext) async throws {
                let counter = dry.get(Int.self, for: "test_counter") ?? 0
                log.rolledBack.append((id, counter))
            }
            func metadata() -> OpMetadata { OpMetadata.builder("ContinueOp\(id)").build() }
        }

        let ops = [
            AnyOp(ContinueOp(id: 1, failOnIteration: nil, log: log)),
            AnyOp(ContinueOp(id: 2, failOnIteration: 1, log: log)),
        ]
        let loopOp = LoopOp(counterVar: "test_counter", limit: 3, ops: ops, continueOnError: true)
        let dry = DryContext(); let wet = WetContext()
        let result = try await loopOp.perform(dry: dry, wet: wet)
        let performed = log.performed
        XCTAssertEqual(performed.map(\.0), [1, 2, 1, 2, 1, 2])
        XCTAssertEqual(result, [1, 2, 1, 1, 2])
        let rolledBack = log.rolledBack
        XCTAssertEqual(rolledBack.count, 1)
        XCTAssertEqual(rolledBack[0].0, 1)
        XCTAssertEqual(rolledBack[0].1, 1)
    }

    // TEST113: Run a LoopOp where an op sets the break flag via context and verify the loop terminates early
    func test_113_loop_op_break_terminates_loop() async throws {
        struct BreakOp: Op {
            typealias Output = Int
            let shouldBreak: Bool
            let value: Int
            func perform(dry: DryContext, wet: WetContext) async throws -> Int {
                if shouldBreak {
                    let loopId = dry.get(String.self, for: "__current_loop_id") ?? ""
                    dry.insert(true, for: "__break_loop_\(loopId)")
                }
                return value
            }
            func metadata() -> OpMetadata { OpMetadata.builder("BreakOp").build() }
        }

        let ops: [AnyOp<Int>] = [
            AnyOp(TestOp(value: 10)),
            AnyOp(BreakOp(shouldBreak: true, value: 99)),
            AnyOp(TestOp(value: 20)), // should NOT execute after break
        ]
        let loopOp = LoopOp(counterVar: "counter", limit: 5, ops: ops)
        let dry = DryContext(); let wet = WetContext()
        let results = try await loopOp.perform(dry: dry, wet: wet)
        XCTAssertEqual(results, [10, 99])
    }

    // TEST114: Run LoopOp with continueOnError where an op fails and verify the loop continues
    func test_114_loop_op_continue_on_error_skips_failed_iterations() async throws {
        final class Seen: @unchecked Sendable { var iterations: [Int] = [] }
        let seen = Seen()

        struct IterOp: Op {
            typealias Output = Int
            let failOn: Int?
            let seen: Seen
            func perform(dry: DryContext, wet: WetContext) async throws -> Int {
                let counter = dry.get(Int.self, for: "it_counter") ?? 0
                seen.iterations.append(counter)
                if failOn == counter { throw OpError.executionFailed("fail on \(counter)") }
                return counter
            }
            func metadata() -> OpMetadata { OpMetadata.builder("IterOp").build() }
        }

        let loopOp = LoopOp(
            counterVar: "it_counter",
            limit: 4,
            ops: [AnyOp(IterOp(failOn: 1, seen: seen))],
            continueOnError: true
        )
        let dry = DryContext(); let wet = WetContext()
        let results = try await loopOp.perform(dry: dry, wet: wet)
        XCTAssertEqual(seen.iterations, [0, 1, 2, 3])
        XCTAssertEqual(results, [0, 2, 3])
    }

    // TEST074: Run a LoopOp that fails on iteration 2 and verify previously completed iterations are not rolled back
    func test_074_loop_op_successful_iterations_not_rolled_back() async {
        final class IterTracker: @unchecked Sendable {
            var performed: [Int] = []
            var rolledBack: [Int] = []
        }
        let tracker = IterTracker()

        struct IterationTrackingOp: Op {
            typealias Output = Int
            let failOnIteration: Int?
            let tracker: IterTracker
            let counterVar: String
            func perform(dry: DryContext, wet: WetContext) async throws -> Int {
                let counter = dry.get(Int.self, for: counterVar) ?? 0
                tracker.performed.append(counter)
                if let fail = failOnIteration, counter == fail {
                    throw OpError.executionFailed("Failed on iteration \(counter)")
                }
                return counter
            }
            func rollback(dry: DryContext, wet: WetContext) async throws {
                let counter = dry.get(Int.self, for: counterVar) ?? 0
                tracker.rolledBack.append(counter)
            }
            func metadata() -> OpMetadata { OpMetadata.builder("IterationTrackingOp").build() }
        }

        let loopOp = LoopOp(
            counterVar: "test_counter",
            limit: 5,
            ops: [AnyOp(IterationTrackingOp(failOnIteration: 2, tracker: tracker, counterVar: "test_counter"))]
        )
        let dry = DryContext()
        let wet = WetContext()
        let result = try? await loopOp.perform(dry: dry, wet: wet)
        XCTAssertNil(result, "Expected loop to fail")

        // Should have executed iterations 0, 1, 2 (fails on 2)
        XCTAssertEqual(tracker.performed, [0, 1, 2], "Should have performed iterations 0, 1, 2")

        // The failing op did not succeed, so it is not rolled back.
        // Successful iterations (0 and 1) are not rolled back — loop only rolls back the current iteration.
        XCTAssertEqual(tracker.rolledBack, [], "No rollback: failing op never succeeded")
    }

    // TEST075: Run a LoopOp where op2 fails on iteration 1 and verify only op1 from that iteration is rolled back
    func test_075_loop_op_mixed_iteration_with_rollback() async {
        final class IterTracker: @unchecked Sendable {
            var performed: [(Int, Int)] = []   // (opId, iteration)
            var rolledBack: [(Int, Int)] = []  // (opId, iteration)
        }
        let tracker = IterTracker()

        struct MixedIterationOp: Op {
            typealias Output = Int
            let id: Int
            let failOnIteration: Int?
            let tracker: IterTracker
            let counterVar: String
            func perform(dry: DryContext, wet: WetContext) async throws -> Int {
                let counter = dry.get(Int.self, for: counterVar) ?? 0
                tracker.performed.append((id, counter))
                if let fail = failOnIteration, counter == fail {
                    throw OpError.executionFailed("Op \(id) failed on iteration \(counter)")
                }
                return id
            }
            func rollback(dry: DryContext, wet: WetContext) async throws {
                let counter = dry.get(Int.self, for: counterVar) ?? 0
                tracker.rolledBack.append((id, counter))
            }
            func metadata() -> OpMetadata { OpMetadata.builder("MixedIterationOp\(id)").build() }
        }

        let loopOp = LoopOp(
            counterVar: "test_counter",
            limit: 3,
            ops: [
                AnyOp(MixedIterationOp(id: 1, failOnIteration: nil, tracker: tracker, counterVar: "test_counter")),
                AnyOp(MixedIterationOp(id: 2, failOnIteration: 1,   tracker: tracker, counterVar: "test_counter")),
            ]
        )
        let dry = DryContext()
        let wet = WetContext()
        let result = try? await loopOp.perform(dry: dry, wet: wet)
        XCTAssertNil(result, "Expected loop to fail")

        // Iteration 0: op1 ✓, op2 ✓  |  Iteration 1: op1 ✓, op2 ✗
        XCTAssertEqual(tracker.performed.map { "\($0.0),\($0.1)" },
                       ["1,0", "2,0", "1,1", "2,1"],
                       "Should have performed all 4 ops across 2 iterations")

        // Only op1 from iteration 1 is rolled back (op2 failed, so it wasn't added to succeeded)
        XCTAssertEqual(tracker.rolledBack.map { "\($0.0),\($0.1)" },
                       ["1,1"],
                       "Should only rollback op1 from the failed iteration")
    }

    // TEST115: Run an empty LoopOp with a non-zero limit and verify it produces no results
    func test_115_loop_op_with_no_ops_produces_no_results() async throws {
        let loopOp = LoopOp<Int>(counterVar: "counter", limit: 5, ops: [])
        let dry = DryContext(); let wet = WetContext()
        let results = try await loopOp.perform(dry: dry, wet: wet)
        XCTAssertTrue(results.isEmpty)
        XCTAssertEqual(dry.get(Int.self, for: "counter"), 5)
    }
}
