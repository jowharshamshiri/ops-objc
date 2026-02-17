import XCTest
@testable import Ops

final class WetContextTests: XCTestCase {

    // TEST011: Insert a reference into WetContext and retrieve it by type via getRef
    func test_011_wet_context_basic_operations() {
        class TestService {
            let name: String
            init(name: String) { self.name = name }
        }
        let ctx = WetContext()
        let service = TestService(name: "test")
        ctx.insertRef(service, for: "service")

        let retrieved = ctx.getRef(TestService.self, for: "service")
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.name, "test")
    }

    // TEST012: Build a WetContext with chained withRef calls and verify contains for each key
    func test_012_wet_context_builder() {
        class Service1 {}
        class Service2 {}

        let ctx = WetContext()
            .withRef(Service1(), for: "service1")
            .withRef(Service2(), for: "service2")

        XCTAssertTrue(ctx.contains("service1"))
        XCTAssertTrue(ctx.contains("service2"))
    }

    // TEST016: Verify WetContext getRequired returns a Type mismatch error when the stored ref type differs
    func test_016_wet_context_type_mismatch_error() {
        class ServiceA { let name = "A" }
        class ServiceB { let id = 1 }

        let ctx = WetContext()
        ctx.insertRef(ServiceA(), for: "service")

        // Wrong type
        XCTAssertThrowsError(try ctx.getRequired(ServiceB.self, for: "service")) { err in
            let msg = (err as! OpError).description
            XCTAssertTrue(msg.contains("Type mismatch"))
            XCTAssertTrue(msg.contains("ServiceB"))
        }

        // Missing key
        XCTAssertThrowsError(try ctx.getRequired(ServiceA.self, for: "missing")) { err in
            let msg = (err as! OpError).description
            XCTAssertTrue(msg.contains("not found"))
            XCTAssertFalse(msg.contains("Type mismatch"))
        }
    }

    // TEST099: Merge two WetContexts and verify both sets of references are accessible in the target
    func test_099_wet_context_merge() {
        class ServiceA {}
        class ServiceB {}

        let ctx1 = WetContext()
        ctx1.insertRef(ServiceA(), for: "a")

        let ctx2 = WetContext()
        ctx2.insertRef(ServiceB(), for: "b")

        ctx1.merge(ctx2)
        XCTAssertTrue(ctx1.contains("a"))
        XCTAssertTrue(ctx1.contains("b"))
    }

    // TEST103: Verify WetContext::keys() returns all inserted reference keys
    func test_103_wet_context_keys() {
        class Svc {}
        let ctx = WetContext()
        ctx.insertRef(Svc(), for: "svc1")
        ctx.insertRef(Svc(), for: "svc2")
        let keys = ctx.keys.sorted()
        XCTAssertEqual(keys, ["svc1", "svc2"])
    }
}
