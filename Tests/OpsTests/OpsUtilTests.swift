import XCTest
@testable import Ops

final class OpsUtilTests: XCTestCase {

    struct TestOp: Op {
        typealias Output = Int
        func perform(dry: DryContext, wet: WetContext) async throws -> Int { 42 }
        func metadata() -> OpMetadata { OpMetadata.builder("TestOp").build() }
    }

    // TEST005: Confirm the perform() utility wraps an op with automatic logging and returns its result
    func test_005_perform_with_auto_logging() async throws {
        let dry = DryContext()
        let wet = WetContext()
        let result = try await Ops.perform(TestOp(), dry: dry, wet: wet)
        XCTAssertEqual(result, 42)
    }

    // TEST006: Verify callerTriggerName() returns a string containing "::"
    func test_006_caller_trigger_name() {
        let name = callerTriggerName()
        XCTAssertTrue(name.contains("OpsUtilTests"))
        XCTAssertTrue(name.contains("::"))
    }

    // TEST007: Confirm wrapNestedOpException wraps an error with the op name in the message
    func test_007_wrap_nested_op_exception() {
        let original = OpError.executionFailed("original error")
        let wrapped = wrapNestedOpException("TestOp", error: original)
        if case .executionFailed(let msg) = wrapped {
            XCTAssertTrue(msg.contains("TestOp"))
            XCTAssertTrue(msg.contains("original error"))
        } else {
            XCTFail("Expected executionFailed")
        }
    }

    // TEST008: Verify wrapRuntimeException converts a standard error into an OpError.executionFailed
    func test_008_wrap_runtime_exception() {
        struct StdErr: Error, Sendable {
            let message: String
            init() { message = "test error" }
        }
        let wrapped = wrapRuntimeException(StdErr())
        if case .executionFailed(let msg) = wrapped {
            XCTAssertTrue(msg.contains("Runtime error"))
            XCTAssertTrue(msg.contains("test error"))
        } else {
            XCTFail("Expected executionFailed")
        }
    }
}
