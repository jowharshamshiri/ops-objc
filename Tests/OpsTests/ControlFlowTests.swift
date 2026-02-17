import XCTest
@testable import Ops

/// Helper ops used across control flow tests.

/// Op that aborts the context and throws OpError.aborted.
private struct AbortTestOp: Op {
    typealias Output = Int
    let shouldAbort: Bool
    let abortReason: String?
    func perform(dry: DryContext, wet: WetContext) async throws -> Int {
        if shouldAbort {
            dry.setAbort(reason: abortReason)
            throw OpError.aborted(abortReason ?? "Operation aborted")
        }
        return 42
    }
    func metadata() -> OpMetadata { OpMetadata.builder("AbortTestOp").build() }
}

/// Op that signals continue-loop via the context flag mechanism (mirrors Rust's continue_loop! macro).
/// Sets __continue_loop_{loopId} in context and returns 0 (default value).
private struct ContinueTestOp: Op {
    typealias Output = Int
    let shouldContinue: Bool
    let value: Int
    func perform(dry: DryContext, wet: WetContext) async throws -> Int {
        if shouldContinue {
            if let loopId = dry.get(String.self, for: "__current_loop_id") {
                dry.insert(true, for: "__continue_loop_\(loopId)")
            }
            return 0 // default, mirrors Rust's Default::default()
        }
        return value
    }
    func metadata() -> OpMetadata { OpMetadata.builder("ContinueTestOp").build() }
}

/// Op that checks the abort flag and short-circuits if set (mirrors Rust's check_abort! macro).
private struct CheckAbortOp: Op {
    typealias Output = Int
    func perform(dry: DryContext, wet: WetContext) async throws -> Int {
        if dry.isAborted {
            throw OpError.aborted(dry.abortReason ?? "aborted")
        }
        return 100
    }
    func metadata() -> OpMetadata { OpMetadata.builder("CheckAbortOp").build() }
}

final class ControlFlowTests: XCTestCase {

    // TEST057: Invoke the abort pattern without a reason and verify the context is aborted with no reason string
    func test_057_abort_without_reason() async {
        let dry = DryContext()
        let wet = WetContext()
        let op = AbortTestOp(shouldAbort: true, abortReason: nil)

        do {
            _ = try await op.perform(dry: dry, wet: wet)
            XCTFail("Expected aborted error")
        } catch OpError.aborted(let msg) {
            XCTAssertTrue(dry.isAborted)
            XCTAssertNil(dry.abortReason)
            XCTAssertEqual(msg, "Operation aborted")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // TEST058: Invoke the abort pattern with a reason string and verify abort_reason matches
    func test_058_abort_with_reason() async {
        let dry = DryContext()
        let wet = WetContext()
        let op = AbortTestOp(shouldAbort: true, abortReason: "Test reason")

        do {
            _ = try await op.perform(dry: dry, wet: wet)
            XCTFail("Expected aborted error")
        } catch OpError.aborted(let msg) {
            XCTAssertTrue(dry.isAborted)
            XCTAssertEqual(dry.abortReason, "Test reason")
            XCTAssertEqual(msg, "Test reason")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // TEST059: Signal continue from inside an op using the context flag and verify subsequent ops are skipped
    func test_059_continue_loop_via_context_flag() async throws {
        final class Tracker: @unchecked Sendable { var executed = false }
        let tracker = Tracker()

        struct ShouldNotRunOp: Op {
            typealias Output = Int
            let tracker: Tracker
            func perform(dry: DryContext, wet: WetContext) async throws -> Int {
                tracker.executed = true
                return 99
            }
            func metadata() -> OpMetadata { OpMetadata.builder("ShouldNotRunOp").build() }
        }

        let loopOp = LoopOp(
            counterVar: "i",
            limit: 1,
            ops: [
                AnyOp(ContinueTestOp(shouldContinue: true, value: 0)),
                AnyOp(ShouldNotRunOp(tracker: tracker))
            ]
        )
        let dry = DryContext()
        let wet = WetContext()
        _ = try await loopOp.perform(dry: dry, wet: wet)
        XCTAssertFalse(tracker.executed, "ShouldNotRunOp must not execute after continue signal")
    }

    // TEST060: Use check_abort pattern to short-circuit when the abort flag is already set in context
    func test_060_check_abort_pattern() async throws {
        let dry = DryContext()
        let wet = WetContext()

        // Without abort flag: returns 100
        let result = try await CheckAbortOp().perform(dry: dry, wet: wet)
        XCTAssertEqual(result, 100)

        // With abort flag: short-circuits and throws
        dry.setAbort(reason: "Pre-existing abort")
        do {
            _ = try await CheckAbortOp().perform(dry: dry, wet: wet)
            XCTFail("Expected aborted error")
        } catch OpError.aborted(let msg) {
            XCTAssertEqual(msg, "Pre-existing abort")
        }
    }

    // TEST061: Run a BatchOp where the second op aborts and verify the batch stops and propagates the abort
    func test_061_batch_op_with_abort() async {
        let ops = [
            AnyOp(AbortTestOp(shouldAbort: false, abortReason: nil)),
            AnyOp(AbortTestOp(shouldAbort: true, abortReason: "Batch abort")),
            AnyOp(AbortTestOp(shouldAbort: false, abortReason: nil)), // should not execute
        ]
        let batch = BatchOp(ops: ops)
        let dry = DryContext()
        let wet = WetContext()

        do {
            _ = try await batch.perform(dry: dry, wet: wet)
            XCTFail("Expected aborted error")
        } catch OpError.aborted(let msg) {
            XCTAssertEqual(msg, "Batch abort")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // TEST062: Start a BatchOp with an abort flag already set and verify it immediately returns Aborted
    func test_062_batch_op_with_pre_existing_abort() async {
        let ops = [
            AnyOp(AbortTestOp(shouldAbort: false, abortReason: nil)),
            AnyOp(AbortTestOp(shouldAbort: false, abortReason: nil)),
        ]
        let batch = BatchOp(ops: ops)
        let dry = DryContext()
        let wet = WetContext()
        dry.setAbort(reason: "Pre-existing abort")

        do {
            _ = try await batch.perform(dry: dry, wet: wet)
            XCTFail("Expected aborted error")
        } catch OpError.aborted(let msg) {
            XCTAssertEqual(msg, "Pre-existing abort")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // TEST063: Run a LoopOp where an op signals continue and verify subsequent ops in the iteration are skipped
    func test_063_loop_op_with_continue() async throws {
        final class Tracker: @unchecked Sendable { var executed = false }
        let tracker = Tracker()

        struct ShouldSkipOp: Op {
            typealias Output = Int
            let tracker: Tracker
            func perform(dry: DryContext, wet: WetContext) async throws -> Int {
                tracker.executed = true
                return 50
            }
            func metadata() -> OpMetadata { OpMetadata.builder("ShouldSkipOp").build() }
        }

        let loopOp = LoopOp(
            counterVar: "test_counter",
            limit: 2,
            ops: [
                AnyOp(ContinueTestOp(shouldContinue: false, value: 10)), // executes, returns 10
                AnyOp(ContinueTestOp(shouldContinue: true,  value: 20)), // sets flag, returns 0
                AnyOp(ShouldSkipOp(tracker: tracker)),                   // should be skipped
            ]
        )
        let dry = DryContext()
        let wet = WetContext()
        let results = try await loopOp.perform(dry: dry, wet: wet)

        // Both iterations: [10, 0] each — the skip op is never executed
        XCTAssertEqual(results, [10, 0, 10, 0])
        XCTAssertFalse(tracker.executed, "ShouldSkipOp must never execute")
    }

    // TEST064: Run a LoopOp where an op aborts mid-loop and verify the loop terminates with the abort error
    func test_064_loop_op_with_abort() async {
        let loopOp = LoopOp(
            counterVar: "test_counter",
            limit: 3,
            ops: [
                AnyOp(AbortTestOp(shouldAbort: false, abortReason: nil)),
                AnyOp(AbortTestOp(shouldAbort: true, abortReason: "Loop abort")),
                AnyOp(AbortTestOp(shouldAbort: false, abortReason: nil)), // should not execute
            ]
        )
        let dry = DryContext()
        let wet = WetContext()

        do {
            _ = try await loopOp.perform(dry: dry, wet: wet)
            XCTFail("Expected aborted error")
        } catch OpError.aborted(let msg) {
            XCTAssertEqual(msg, "Loop abort")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // TEST065: Start a LoopOp with an abort flag already set and verify it immediately returns Aborted
    func test_065_loop_op_with_pre_existing_abort() async {
        let loopOp = LoopOp(
            counterVar: "test_counter",
            limit: 2,
            ops: [AnyOp(AbortTestOp(shouldAbort: false, abortReason: nil))]
        )
        let dry = DryContext()
        let wet = WetContext()
        dry.setAbort(reason: "Pre-existing loop abort")

        do {
            _ = try await loopOp.perform(dry: dry, wet: wet)
            XCTFail("Expected aborted error")
        } catch OpError.aborted(let msg) {
            XCTAssertEqual(msg, "Pre-existing loop abort")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // TEST066: Nest a batch with a continue op inside a loop and verify results across all iterations
    func test_066_complex_control_flow_scenario() async throws {
        // BatchOp containing [normal(100), continue(200)].
        // continue op sets the flag and returns 0. BatchOp returns [100, 0] per iteration.
        // LoopOp sees the flag after BatchOp finishes and continues to next iteration.
        let batchOps = [
            AnyOp(ContinueTestOp(shouldContinue: false, value: 100)),
            AnyOp(ContinueTestOp(shouldContinue: true, value: 200)),
        ]
        let batch = BatchOp(ops: batchOps)

        let loopOp = LoopOp(
            counterVar: "complex_counter",
            limit: 2,
            ops: [AnyOp(batch)]
        )
        let dry = DryContext()
        let wet = WetContext()
        let results = try await loopOp.perform(dry: dry, wet: wet)

        // Each iteration returns [100, 0] (from batch), and there are 2 iterations.
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0], [100, 0])
        XCTAssertEqual(results[1], [100, 0])
    }
}
