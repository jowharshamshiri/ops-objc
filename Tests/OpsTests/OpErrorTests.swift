import XCTest
@testable import Ops

final class OpErrorTests: XCTestCase {

    // TEST104: Verify OpError.executionFailed displays with the correct message format
    func test_104_op_error_display_execution_failed() {
        let err = OpError.executionFailed("something broke")
        XCTAssertEqual(err.description, "Op execution failed: something broke")
    }

    // TEST105: Verify OpError.timeout displays with the correct timeout_ms value
    func test_105_op_error_display_timeout() {
        let err = OpError.timeout(timeoutMs: 250)
        XCTAssertEqual(err.description, "Op timeout after 250ms")
    }

    // TEST106: Verify OpError.context displays with the correct message format
    func test_106_op_error_display_context() {
        let err = OpError.context("missing key")
        XCTAssertEqual(err.description, "Context error: missing key")
    }

    // TEST107: Verify OpError.aborted displays with the correct message format
    func test_107_op_error_display_aborted() {
        let err = OpError.aborted("user cancelled")
        XCTAssertEqual(err.description, "Op aborted: user cancelled")
    }

    // TEST108: Clone (copy) an OpError.executionFailed and verify the copy is identical
    func test_108_op_error_copy_execution_failed() {
        let err = OpError.executionFailed("fail msg")
        // Swift enums are value types — assignment is a copy
        let copy = err
        XCTAssertEqual(err.description, copy.description)
        if case .executionFailed(let msg) = copy {
            XCTAssertEqual(msg, "fail msg")
        } else {
            XCTFail("wrong variant")
        }
    }

    // TEST109: Copy OpError.timeout and verify timeoutMs is preserved
    func test_109_op_error_copy_timeout() {
        let err = OpError.timeout(timeoutMs: 500)
        let copy = err
        if case .timeout(let ms) = copy {
            XCTAssertEqual(ms, 500)
        } else {
            XCTFail("wrong variant")
        }
    }

    // TEST110: Verify OpError.other holds the wrapped error's description
    func test_110_op_error_other_holds_error() {
        struct TestError: Error, Sendable {
            let msg: String
            var localizedDescription: String { msg }
        }
        let err = OpError.other(TestError(msg: "file missing"))
        XCTAssertTrue(err.description.contains("file missing"))
    }

    // TEST111: Convert a JSON decoding error into OpError via wrapping
    func test_111_op_error_from_json_error() {
        struct TestError: Error, Sendable {
            let msg: String
            var localizedDescription: String { msg }
        }
        // In Swift we wrap errors manually (no From impl like Rust)
        let jsonErr = TestError(msg: "invalid json")
        let opErr = OpError.other(jsonErr)
        if case .other(_) = opErr {
            // correct
        } else {
            XCTFail("expected other variant")
        }
    }
}
