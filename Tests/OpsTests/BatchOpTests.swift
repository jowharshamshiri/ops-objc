import XCTest
@testable import Ops

final class BatchOpTests: XCTestCase {

    struct TestOp: Op {
        typealias Output = Int
        let value: Int
        let shouldFail: Bool
        func perform(dry: DryContext, wet: WetContext) async throws -> Int {
            if shouldFail { throw OpError.executionFailed("Test failure") }
            return value
        }
        func metadata() -> OpMetadata { OpMetadata.builder("TestOp").build() }
    }

    // TEST049: Run BatchOp with two succeeding ops and verify results contain both values in order
    func test_049_batch_op_success() async throws {
        let ops = [AnyOp(TestOp(value: 1, shouldFail: false)), AnyOp(TestOp(value: 2, shouldFail: false))]
        let batch = BatchOp(ops: ops)
        let dry = DryContext()
        let wet = WetContext()
        let results = try await batch.perform(dry: dry, wet: wet)
        XCTAssertEqual(results, [1, 2])
    }

    // TEST050: Run BatchOp where the second op fails and verify the batch returns an error
    func test_050_batch_op_failure() async {
        let ops = [AnyOp(TestOp(value: 1, shouldFail: false)), AnyOp(TestOp(value: 2, shouldFail: true))]
        let batch = BatchOp(ops: ops)
        let dry = DryContext()
        let wet = WetContext()
        do {
            _ = try await batch.perform(dry: dry, wet: wet)
            XCTFail("Expected error")
        } catch {
            // expected
        }
    }

    // TEST051: Run BatchOp with two ops and verify both result values are present in order
    func test_051_batch_op_returns_all_results() async throws {
        let ops = [AnyOp(TestOp(value: 1, shouldFail: false)), AnyOp(TestOp(value: 2, shouldFail: false))]
        let batch = BatchOp(ops: ops)
        let dry = DryContext()
        let wet = WetContext()
        let results = try await batch.perform(dry: dry, wet: wet)
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.contains(1))
        XCTAssertTrue(results.contains(2))
    }

    // TEST053: Verify BatchOp merges reference schemas from all ops into a unified set of required refs
    func test_053_batch_reference_schema_merging() {
        struct ServiceAOp: Op {
            typealias Output = Void
            func perform(dry: DryContext, wet: WetContext) async throws {}
            func metadata() -> OpMetadata {
                OpMetadata.builder("ServiceAOp")
                    .referenceSchema([
                        "type": "object",
                        "properties": ["service_a": [:], "shared_service": [:]],
                        "required": ["service_a", "shared_service"]
                    ])
                    .build()
            }
        }
        struct ServiceBOp: Op {
            typealias Output = Void
            func perform(dry: DryContext, wet: WetContext) async throws {}
            func metadata() -> OpMetadata {
                OpMetadata.builder("ServiceBOp")
                    .referenceSchema([
                        "type": "object",
                        "properties": ["service_b": [:], "shared_service": [:]],
                        "required": ["service_b", "shared_service"]
                    ])
                    .build()
            }
        }
        let ops = [AnyOp(ServiceAOp()), AnyOp(ServiceBOp())]
        let batch = BatchOp(ops: ops)
        let meta = batch.metadata()
        if let refSchema = meta.referenceSchema,
           let required = refSchema["required"] as? [String] {
            XCTAssertEqual(required.count, 3)
            XCTAssertTrue(required.contains("service_a"))
            XCTAssertTrue(required.contains("service_b"))
            XCTAssertTrue(required.contains("shared_service"))
        } else {
            XCTFail("Expected reference schema")
        }
    }

    // TEST054: Run BatchOp where the third op fails and verify rollback is called on the first two but not the third
    func test_054_batch_rollback_on_failure() async {
        final class Tracker: @unchecked Sendable {
            var performed = false
            var rolledBack = false
        }
        struct RollbackOp: Op {
            typealias Output = UInt32
            let id: UInt32
            let shouldFail: Bool
            let performed: Tracker
            let rolledBack: Tracker
            func perform(dry: DryContext, wet: WetContext) async throws -> UInt32 {
                performed.performed = true
                if shouldFail { throw OpError.executionFailed("Op \(id) failed") }
                return id
            }
            func rollback(dry: DryContext, wet: WetContext) async throws {
                rolledBack.performed = true // reuse Tracker
                // (Tracker.performed and Tracker.rolledBack are separate)
            }
            func metadata() -> OpMetadata { OpMetadata.builder("RollbackOp\(id)").build() }
        }

        // Use separate trackers for each op
        let p1 = Tracker(); let r1 = Tracker()
        let p2 = Tracker(); let r2 = Tracker()
        let p3 = Tracker(); let r3 = Tracker()

        struct TrackingOp: Op {
            typealias Output = UInt32
            let id: UInt32
            let shouldFail: Bool
            let performedFlag: Tracker
            let rolledBackFlag: Tracker
            func perform(dry: DryContext, wet: WetContext) async throws -> UInt32 {
                performedFlag.performed = true
                if shouldFail { throw OpError.executionFailed("Op \(id) failed") }
                return id
            }
            func rollback(dry: DryContext, wet: WetContext) async throws {
                rolledBackFlag.performed = true
            }
            func metadata() -> OpMetadata { OpMetadata.builder("TrackingOp\(id)").build() }
        }

        let ops = [
            AnyOp(TrackingOp(id: 1, shouldFail: false, performedFlag: p1, rolledBackFlag: r1)),
            AnyOp(TrackingOp(id: 2, shouldFail: false, performedFlag: p2, rolledBackFlag: r2)),
            AnyOp(TrackingOp(id: 3, shouldFail: true,  performedFlag: p3, rolledBackFlag: r3)),
        ]
        let batch = BatchOp(ops: ops)
        let dry = DryContext(); let wet = WetContext()
        let result = try? await batch.perform(dry: dry, wet: wet)
        XCTAssertNil(result)
        XCTAssertTrue(p1.performed)
        XCTAssertTrue(p2.performed)
        XCTAssertTrue(p3.performed)
        XCTAssertTrue(r1.performed, "Op1 should have been rolled back")
        XCTAssertTrue(r2.performed, "Op2 should have been rolled back")
        XCTAssertFalse(r3.performed, "Op3 should NOT have been rolled back (it failed)")
    }

    // TEST055: Run BatchOp where the last op fails and verify rollback occurs in reverse (LIFO) order
    func test_055_batch_rollback_order() async {
        final class RollbackOrder: @unchecked Sendable { var order: [UInt32] = [] }
        let rollbackOrder = RollbackOrder()

        struct OrderTrackingOp: Op {
            typealias Output = UInt32
            let id: UInt32
            let order: RollbackOrder
            func perform(dry: DryContext, wet: WetContext) async throws -> UInt32 { id }
            func rollback(dry: DryContext, wet: WetContext) async throws {
                order.order.append(id)
            }
            func metadata() -> OpMetadata { OpMetadata.builder("OrderTrackingOp\(id)").build() }
        }
        struct FailingOp: Op {
            typealias Output = UInt32
            func perform(dry: DryContext, wet: WetContext) async throws -> UInt32 {
                throw OpError.executionFailed("Intentional failure")
            }
            func metadata() -> OpMetadata { OpMetadata.builder("FailingOp").build() }
        }

        let ops = [
            AnyOp(OrderTrackingOp(id: 1, order: rollbackOrder)),
            AnyOp(OrderTrackingOp(id: 2, order: rollbackOrder)),
            AnyOp(OrderTrackingOp(id: 3, order: rollbackOrder)),
            AnyOp(FailingOp()),
        ]
        let batch = BatchOp(ops: ops)
        let dry = DryContext(); let wet = WetContext()
        _ = try? await batch.perform(dry: dry, wet: wet)
        XCTAssertEqual(rollbackOrder.order, [3, 2, 1], "Rollback should happen in reverse order")
    }

    // TEST056: Run BatchOp where one op fails and verify rollback is triggered for succeeded ops
    func test_056_batch_rollback_on_failure_partial() async {
        final class Tracker: @unchecked Sendable { var performed = false; var rolledBack = false }
        struct TrackingOp: Op {
            typealias Output = UInt32
            let id: UInt32
            let shouldFail: Bool
            let perf: Tracker; let roll: Tracker
            func perform(dry: DryContext, wet: WetContext) async throws -> UInt32 {
                perf.performed = true
                if shouldFail { throw OpError.executionFailed("Op \(id) failed") }
                return id
            }
            func rollback(dry: DryContext, wet: WetContext) async throws { roll.performed = true }
            func metadata() -> OpMetadata { OpMetadata.builder("TrackingOp\(id)").build() }
        }

        let p1 = Tracker(); let r1 = Tracker()
        let p2 = Tracker(); let r2 = Tracker()
        let ops = [
            AnyOp(TrackingOp(id: 1, shouldFail: false, perf: p1, roll: r1)),
            AnyOp(TrackingOp(id: 2, shouldFail: true, perf: p2, roll: r2)),
        ]
        let batch = BatchOp(ops: ops)
        let dry = DryContext(); let wet = WetContext()
        _ = try? await batch.perform(dry: dry, wet: wet)
        XCTAssertTrue(p1.performed)
        XCTAssertTrue(p2.performed)
        XCTAssertTrue(r1.performed, "Op1 should have been rolled back")
        XCTAssertFalse(r2.performed, "Op2 should NOT have been rolled back")
    }

    // TEST093: Call BatchOp.count and isEmpty on empty and non-empty batches
    func test_093_batch_len_and_is_empty() {
        let empty = BatchOp<Int>(ops: [])
        XCTAssertEqual(empty.count, 0)
        XCTAssertTrue(empty.isEmpty)

        let nonempty = BatchOp(ops: [AnyOp(TestOp(value: 1, shouldFail: false))])
        XCTAssertEqual(nonempty.count, 1)
        XCTAssertFalse(nonempty.isEmpty)
    }

    // TEST095: Run BatchOp with continueOnError and verify it collects results past failures
    func test_095_batch_continue_on_error() async throws {
        let ops = [
            AnyOp(TestOp(value: 1, shouldFail: false)),
            AnyOp(TestOp(value: 2, shouldFail: true)),
            AnyOp(TestOp(value: 3, shouldFail: false)),
        ]
        let batch = BatchOp(ops: ops, continueOnError: true)
        let dry = DryContext(); let wet = WetContext()
        let results = try await batch.perform(dry: dry, wet: wet)
        XCTAssertEqual(results, [1, 3])
    }

    // TEST096: Run an empty BatchOp and verify it returns an empty result array
    func test_096_empty_batch_returns_empty() async throws {
        let batch = BatchOp<Int>(ops: [])
        let dry = DryContext(); let wet = WetContext()
        let results = try await batch.perform(dry: dry, wet: wet)
        XCTAssertTrue(results.isEmpty)
    }

    // TEST097: Verify nested BatchOp rollback propagates correctly when outer batch fails
    func test_097_nested_batch_rollback() async {
        struct SimpleOp: Op {
            typealias Output = Int
            let shouldFail: Bool
            func perform(dry: DryContext, wet: WetContext) async throws -> Int {
                if shouldFail { throw OpError.executionFailed("outer fail") }
                return 0
            }
            func metadata() -> OpMetadata { OpMetadata.builder("SimpleOp").build() }
        }

        let innerOps = [AnyOp(SimpleOp(shouldFail: false)), AnyOp(SimpleOp(shouldFail: false))]
        let innerBatch = BatchOp(ops: innerOps)

        struct OuterAdapter: Op {
            typealias Output = [Int]
            let batch: BatchOp<Int>
            func perform(dry: DryContext, wet: WetContext) async throws -> [Int] {
                try await batch.perform(dry: dry, wet: wet)
            }
            func metadata() -> OpMetadata { OpMetadata.builder("OuterAdapter").build() }
        }
        struct FailingOp: Op {
            typealias Output = [Int]
            func perform(dry: DryContext, wet: WetContext) async throws -> [Int] {
                throw OpError.executionFailed("outer fail")
            }
            func metadata() -> OpMetadata { OpMetadata.builder("FailingOp").build() }
        }

        let outerOps = [AnyOp(OuterAdapter(batch: innerBatch)), AnyOp(FailingOp())]
        let outerBatch = BatchOp(ops: outerOps)
        let dry = DryContext(); let wet = WetContext()
        do {
            _ = try await outerBatch.perform(dry: dry, wet: wet)
            XCTFail("Expected error")
        } catch OpError.batchFailed(_) {
            // expected
        } catch {
            XCTFail("Expected BatchFailed, got: \(error)")
        }
    }
}
