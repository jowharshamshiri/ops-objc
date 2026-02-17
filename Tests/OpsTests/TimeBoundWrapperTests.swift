import XCTest
@testable import Ops

final class TimeBoundWrapperTests: XCTestCase {

    struct SlowOp: Op {
        typealias Output = Int
        func perform(dry: DryContext, wet: WetContext) async throws -> Int {
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms
            return 42
        }
        func metadata() -> OpMetadata { OpMetadata.builder("SlowOp").build() }
    }

    struct VerySlowOp: Op {
        typealias Output = Int
        func perform(dry: DryContext, wet: WetContext) async throws -> Int {
            try await Task.sleep(nanoseconds: 200_000_000) // 200ms
            return 42
        }
        func metadata() -> OpMetadata { OpMetadata.builder("VerySlowOp").build() }
    }

    struct StringOp: Op {
        typealias Output = String
        func perform(dry: DryContext, wet: WetContext) async throws -> String { "success" }
        func metadata() -> OpMetadata { OpMetadata.builder("StringOp").build() }
    }

    struct IntOp: Op {
        typealias Output = Int
        func perform(dry: DryContext, wet: WetContext) async throws -> Int { 100 }
        func metadata() -> OpMetadata { OpMetadata.builder("IntOp").build() }
    }

    struct CompositeOp: Op {
        typealias Output = String
        func perform(dry: DryContext, wet: WetContext) async throws -> String { "logged and timed" }
        func metadata() -> OpMetadata { OpMetadata.builder("CompositeOp").build() }
    }

    // TEST033: Wrap a fast op in TimeBoundWrapper and confirm it completes before the timeout
    func test_033_timeout_wrapper_success() async throws {
        let dry = DryContext()
        let wet = WetContext()
        let wrapper = TimeBoundWrapper(op: AnyOp(SlowOp()), timeout: 0.2)
        let result = try await wrapper.perform(dry: dry, wet: wet)
        XCTAssertEqual(result, 42)
    }

    // TEST034: Wrap a slow op in TimeBoundWrapper with a short timeout and verify a Timeout error is returned
    func test_034_timeout_wrapper_timeout() async {
        let dry = DryContext()
        let wet = WetContext()
        let wrapper = TimeBoundWrapper(op: AnyOp(VerySlowOp()), timeout: 0.05)
        do {
            _ = try await wrapper.perform(dry: dry, wet: wet)
            XCTFail("Expected timeout")
        } catch OpError.timeout(let ms) {
            XCTAssertEqual(ms, 50)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // TEST035: Create a named TimeBoundWrapper and verify the op succeeds and returns the expected value
    func test_035_timeout_wrapper_with_name() async throws {
        let dry = DryContext()
        let wet = WetContext()
        let wrapper = TimeBoundWrapper(op: AnyOp(StringOp()), timeout: 0.1, name: "TestOp")
        let result = try await wrapper.perform(dry: dry, wet: wet)
        XCTAssertEqual(result, "success")
    }

    // TEST036: Use createTimeoutWrapperWithCallerName helper and verify the op result is returned
    func test_036_caller_name_wrapper() async throws {
        let dry = DryContext()
        let wet = WetContext()
        let wrapper = createTimeoutWrapperWithCallerName(AnyOp(IntOp()), timeout: 0.1)
        let result = try await wrapper.perform(dry: dry, wet: wet)
        XCTAssertEqual(result, 100)
    }

    // TEST037: Use createLoggedTimeoutWrapper to compose logging and timeout wrappers and verify success
    func test_037_logged_timeout_wrapper() async throws {
        let dry = DryContext()
        let wet = WetContext()
        let wrapped = createLoggedTimeoutWrapper(AnyOp(CompositeOp()), timeout: 0.1, triggerName: "CompositeOp")
        let result = try await wrapped.perform(dry: dry, wet: wet)
        XCTAssertEqual(result, "logged and timed")
    }
}
