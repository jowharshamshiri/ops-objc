import XCTest
@testable import Ops

final class LoggingWrapperTests: XCTestCase {

    struct TestOp: Op {
        typealias Output = Int
        func perform(dry: DryContext, wet: WetContext) async throws -> Int { 42 }
        func metadata() -> OpMetadata { OpMetadata.builder("TestOp").build() }
    }

    struct FailingOp: Op {
        typealias Output = Int
        func perform(dry: DryContext, wet: WetContext) async throws -> Int {
            throw OpError.executionFailed("test error")
        }
        func metadata() -> OpMetadata { OpMetadata.builder("FailingOp").build() }
    }

    struct StringOp: Op {
        typealias Output = String
        func perform(dry: DryContext, wet: WetContext) async throws -> String { "test" }
        func metadata() -> OpMetadata { OpMetadata.builder("StringOp").build() }
    }

    // TEST029: Wrap a successful op in LoggingWrapper and verify it passes through the result unchanged
    func test_029_logging_wrapper_success() async throws {
        let dry = DryContext()
        let wet = WetContext()
        let wrapper = LoggingWrapper(op: AnyOp(TestOp()), name: "TestOp")
        let result = try await wrapper.perform(dry: dry, wet: wet)
        XCTAssertEqual(result, 42)
    }

    // TEST030: Wrap a failing op in LoggingWrapper and verify the error includes the op name context
    func test_030_logging_wrapper_failure() async {
        let dry = DryContext()
        let wet = WetContext()
        let wrapper = LoggingWrapper<Int>(op: AnyOp(FailingOp()), name: "FailingOp")
        do {
            _ = try await wrapper.perform(dry: dry, wet: wet)
            XCTFail("Expected error")
        } catch let err as OpError {
            XCTAssertTrue(err.description.contains("FailingOp"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // TEST031: Use createContextAwareLogger helper and verify the wrapped op returns its result
    func test_031_context_aware_logger() async throws {
        let dry = DryContext()
        let wet = WetContext()
        let wrapper = createContextAwareLogger(AnyOp(StringOp()))
        let result = try await wrapper.perform(dry: dry, wet: wet)
        XCTAssertEqual(result, "test")
    }

    // TEST032: Verify ANSI color escape code constants have the expected ANSI sequence values
    func test_032_ansi_color_constants() {
        XCTAssertEqual(ANSIColors.yellow, "\u{1b}[33m")
        XCTAssertEqual(ANSIColors.green, "\u{1b}[32m")
        XCTAssertEqual(ANSIColors.red, "\u{1b}[31m")
        XCTAssertEqual(ANSIColors.reset, "\u{1b}[0m")
    }
}
