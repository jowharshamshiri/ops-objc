import XCTest
@testable import Ops

final class ContextHelpersTests: XCTestCase {

    // TEST077: Use dryPut and dryGet to store and retrieve a typed value by variable name
    func test_077_dry_put_and_get() {
        let dry = DryContext()
        let value = 42
        dryPut(value, for: "value", in: dry)
        let retrieved = dryGet(Int.self, for: "value", from: dry)
        XCTAssertEqual(retrieved, 42)
    }

    // TEST078: Use dryRequire to retrieve a required value and verify error when key is missing
    func test_078_dry_require() throws {
        let dry = DryContext()
        let name = "test"
        dryPut(name, for: "name", in: dry)

        let result = try dryRequire(String.self, for: "name", from: dry)
        XCTAssertEqual(result, "test")

        XCTAssertThrowsError(try dryRequire(Int.self, for: "missing_value", from: dry))
    }

    // TEST079: Use dryResult to store a final result and verify it is stored under both "result" and op name
    func test_079_dry_result() {
        let dry = DryContext()
        let finalValue = "completed"
        dryResult(finalValue, opName: "TestOp", in: dry)

        XCTAssertEqual(dry.get(String.self, for: "result"), "completed")
        XCTAssertEqual(dry.get(String.self, for: "TestOp"), "completed")
    }

    // TEST080: Use wetPutRef and wetRequireRef to store and retrieve a service reference
    func test_080_wet_put_ref_and_require_ref() throws {
        class TestService {
            let value: Int
            init(value: Int) { self.value = value }
        }
        let wet = WetContext()
        let service = TestService(value: 100)
        wetPutRef(service, for: "service", in: wet)

        let retrieved = try wetRequireRef(TestService.self, for: "service", from: wet)
        XCTAssertEqual(retrieved.value, 100)
    }

    // TEST081: Store a service via wetPutRef and retrieve it via wetRequireRef
    func test_081_wet_put_ref_arc_style() throws {
        class TestService {
            let value: Int
            init(value: Int) { self.value = value }
        }
        let wet = WetContext()
        let sharedService = TestService(value: 200)
        wetPutRef(sharedService, for: "shared_service", in: wet)

        let retrieved = try wetRequireRef(TestService.self, for: "shared_service", from: wet)
        XCTAssertEqual(retrieved.value, 200)
    }

    // TEST082: Run a full op that uses dryRequire and wetRequireRef helpers internally and verify the output
    func test_082_helpers_in_op() async throws {
        class TestService {
            let value: Int
            init(value: Int) { self.value = value }
        }
        struct MacroTestOp: Op {
            typealias Output = String
            func perform(dry: DryContext, wet: WetContext) async throws -> String {
                let input = try dryRequire(String.self, for: "input", from: dry)
                let count = try dryRequire(Int.self, for: "count", from: dry)
                let service = try wetRequireRef(TestService.self, for: "service", from: wet)
                return "\(input) x \(count) = \(service.value)"
            }
            func metadata() -> OpMetadata { OpMetadata.builder("MacroTestOp").build() }
        }

        let dry = DryContext()
        dryPut("test", for: "input", in: dry)
        dryPut(3, for: "count", in: dry)

        let wet = WetContext()
        wetPutRef(TestService(value: 42), for: "service", in: wet)

        let result = try await MacroTestOp().perform(dry: dry, wet: wet)
        XCTAssertEqual(result, "test x 3 = 42")
    }
}
