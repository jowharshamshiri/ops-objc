import XCTest
@testable import Ops

final class OpTests: XCTestCase {

    struct TestOp: Op {
        typealias Output = Int
        let value: Int
        func perform(dry: DryContext, wet: WetContext) async throws -> Int { value }
        func metadata() -> OpMetadata { OpMetadata.builder("TestOp").build() }
    }

    // TEST001: Run Op::perform and verify the returned value matches what the op was configured with
    func test_001_op_execution() async throws {
        let op = TestOp(value: 42)
        let dry = DryContext()
        let wet = WetContext()
        let result = try await op.perform(dry: dry, wet: wet)
        XCTAssertEqual(result, 42)
    }

    // TEST002: Verify Op reads from DryContext and produces a formatted result using that data
    func test_002_op_with_contexts() async throws {
        struct ContextUsingOp: Op {
            typealias Output = String
            func perform(dry: DryContext, wet: WetContext) async throws -> String {
                let name = try dry.getRequired(String.self, for: "name")
                return "Hello, \(name)!"
            }
            func metadata() -> OpMetadata { OpMetadata.builder("ContextUsingOp").build() }
        }

        let dry = DryContext().with(value: "World", for: "name")
        let wet = WetContext()
        let result = try await ContextUsingOp().perform(dry: dry, wet: wet)
        XCTAssertEqual(result, "Hello, World!")
    }

    // TEST003: Confirm that the default rollback implementation is a no-op that always succeeds
    func test_003_op_default_rollback() async throws {
        struct SimpleOp: Op {
            typealias Output = Void
            func perform(dry: DryContext, wet: WetContext) async throws {}
            func metadata() -> OpMetadata { OpMetadata.builder("SimpleOp").build() }
        }
        let dry = DryContext()
        let wet = WetContext()
        // Default rollback should be a no-op and succeed
        try await SimpleOp().rollback(dry: dry, wet: wet)
    }

    // TEST004: Verify a custom rollback implementation is called and sets the rolled_back flag
    func test_004_op_custom_rollback() async throws {
        final class Tracker: @unchecked Sendable {
            var performed = false
            var rolledBack = false
        }
        struct RollbackTrackingOp: Op {
            typealias Output = Void
            let tracker: Tracker
            func perform(dry: DryContext, wet: WetContext) async throws {
                tracker.performed = true
            }
            func rollback(dry: DryContext, wet: WetContext) async throws {
                tracker.rolledBack = true
            }
            func metadata() -> OpMetadata { OpMetadata.builder("RollbackTrackingOp").build() }
        }

        let tracker = Tracker()
        let op = RollbackTrackingOp(tracker: tracker)
        let dry = DryContext()
        let wet = WetContext()

        try await op.perform(dry: dry, wet: wet)
        XCTAssertTrue(tracker.performed)
        XCTAssertFalse(tracker.rolledBack)

        try await op.rollback(dry: dry, wet: wet)
        XCTAssertTrue(tracker.performed)
        XCTAssertTrue(tracker.rolledBack)
    }
}
