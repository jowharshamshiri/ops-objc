import XCTest
@testable import Ops

final class OpErrorTests: XCTestCase {

    // TEST0104: Verify OpError.executionFailed displays with the correct message format
    func test0104_op_error_display_execution_failed() {
        let err = OpError.executionFailed("something broke")
        XCTAssertEqual(err.description, "Op execution failed: something broke")
    }

    // TEST0105: Verify OpError.timeout displays with the correct timeout_ms value
    func test0105_op_error_display_timeout() {
        let err = OpError.timeout(timeoutMs: 250)
        XCTAssertEqual(err.description, "Op timeout after 250ms")
    }

    // TEST0106: Verify OpError.context displays with the correct message format
    func test0106_op_error_display_context() {
        let err = OpError.context("missing key")
        XCTAssertEqual(err.description, "Context error: missing key")
    }

    // TEST0107: Verify OpError.aborted displays with the correct message format
    func test0107_op_error_display_aborted() {
        let err = OpError.aborted("user cancelled")
        XCTAssertEqual(err.description, "Op aborted: user cancelled")
    }

    // TEST0108: Clone (copy) an OpError.executionFailed and verify the copy is identical
    func test0108_op_error_copy_execution_failed() {
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

    // TEST0109: Copy OpError.timeout and verify timeoutMs is preserved
    func test0109_op_error_copy_timeout() {
        let err = OpError.timeout(timeoutMs: 500)
        let copy = err
        if case .timeout(let ms) = copy {
            XCTAssertEqual(ms, 500)
        } else {
            XCTFail("wrong variant")
        }
    }

    // TEST0110: Verify OpError.other holds the wrapped error's description
    func test0110_op_error_other_holds_error() {
        struct TestError: Error, Sendable {
            let msg: String
            var localizedDescription: String { msg }
        }
        let err = OpError.other(TestError(msg: "file missing"))
        XCTAssertTrue(err.description.contains("file missing"))
    }

    // TEST0111: Convert a JSON decoding error into OpError via wrapping
    func test0111_op_error_from_json_error() {
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

    // TEST1730: the wire vocabulary round-trips exactly and rejects
    // unknowns. (mirrors Rust ops/src/failure.rs TEST1730)
    func test1730_failure_class_wire_tokens_round_trip() {
        for klass in FailureClass.allCases {
            XCTAssertEqual(FailureClass(rawValue: klass.rawValue), klass)
        }
        XCTAssertNil(FailureClass(rawValue: "user-error"))
        XCTAssertNil(FailureClass(rawValue: ""))
    }

    // TEST1731: only input is permanent — the retry machinery keys on this.
    // (mirrors Rust ops/src/failure.rs TEST1731)
    func test1731_only_input_is_permanent() {
        XCTAssertTrue(FailureClass.input.isPermanent)
        XCTAssertFalse(FailureClass.resource.isPermanent)
        XCTAssertFalse(FailureClass.environment.isPermanent)
        XCTAssertFalse(FailureClass.internal.isPermanent)
    }

    // TEST1901: classified variants carry the emit source's identity through
    // the accessors; unclassified variants are internal with no code — the
    // taxonomy's own rule (docs/failure-taxonomy.md).
    // (mirrors Rust ops/src/error.rs TEST1901)
    func test1901_classified_accessors() {
        let classified = OpError.classified(
            code: "CONTEXT_OVERFLOW", failureClass: .input, message: "prompt too large",
            argUrn: "media:enc=utf-8;prompt")
        XCTAssertEqual(classified.failureClass, .input)
        XCTAssertEqual(classified.failureCode, "CONTEXT_OVERFLOW")
        XCTAssertEqual(classified.failureReason, "prompt too large")
        XCTAssertEqual(classified.failureArgUrn, "media:enc=utf-8;prompt")
        XCTAssertEqual(classified.description, "CONTEXT_OVERFLOW: prompt too large")

        let wrapped = OpError.wrappedClassified(
            chain: "Op 3-generate failed: CONTEXT_OVERFLOW: prompt too large",
            code: "CONTEXT_OVERFLOW", failureClass: .input, reason: "prompt too large", argUrn: nil)
        XCTAssertEqual(wrapped.failureReason, "prompt too large",
                       "the reason is the LEAF message, not the wrap chain")
        XCTAssertEqual(wrapped.description,
                       "Op 3-generate failed: CONTEXT_OVERFLOW: prompt too large")
        XCTAssertNil(wrapped.failureArgUrn)

        let plain = OpError.executionFailed("boom")
        XCTAssertEqual(plain.failureClass, .internal)
        XCTAssertNil(plain.failureCode)
    }

    // TEST1903: wrapping preserves a classified failure's identity — the
    // wrap enriches the human CHAIN only, never the class/code/reason
    // (docs/failure-taxonomy.md). (mirrors Rust ops/src/ops.rs TEST1903)
    func test1903_wrap_preserves_classification() {
        let wrapped = wrapNestedOpException(
            "GenerateOp",
            error: .classified(code: "CONTEXT_OVERFLOW", failureClass: .input,
                               message: "prompt too large", argUrn: "media:enc=utf-8;prompt"))
        guard case .wrappedClassified(let chain, let code, let failureClass, let reason, let argUrn) = wrapped else {
            XCTFail("expected wrappedClassified, got \(wrapped)")
            return
        }
        XCTAssertTrue(chain.contains("GenerateOp"), "the wrap names the op")
        XCTAssertEqual(code, "CONTEXT_OVERFLOW")
        XCTAssertEqual(failureClass, .input)
        XCTAssertEqual(reason, "prompt too large")
        XCTAssertEqual(argUrn, "media:enc=utf-8;prompt")

        let rewrapped = wrapNestedOpException("OuterBatch", error: wrapped)
        guard case .wrappedClassified(let chain2, let code2, let class2, let reason2, let argUrn2) = rewrapped else {
            XCTFail("expected wrappedClassified after re-wrap, got \(rewrapped)")
            return
        }
        XCTAssertTrue(chain2.contains("OuterBatch") && chain2.contains("GenerateOp"))
        XCTAssertEqual(code2, "CONTEXT_OVERFLOW")
        XCTAssertEqual(class2, .input)
        XCTAssertEqual(reason2, "prompt too large")
        XCTAssertEqual(argUrn2, "media:enc=utf-8;prompt")
    }
}
