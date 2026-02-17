import XCTest
@testable import Ops

final class DryContextTests: XCTestCase {

    // TEST009: Insert typed values into DryContext and verify get/contains work correctly
    func test_009_dry_context_basic_operations() {
        let ctx = DryContext()
        ctx.insert("test", for: "name")
        ctx.insert(42, for: "count")

        XCTAssertEqual(ctx.get(String.self, for: "name"), "test")
        XCTAssertEqual(ctx.get(Int.self, for: "count"), 42)
        XCTAssertTrue(ctx.contains("name"))
        XCTAssertFalse(ctx.contains("missing"))
    }

    // TEST010: Build a DryContext with chained with-value calls and verify all values are stored
    func test_010_dry_context_builder() {
        let ctx = DryContext()
            .with(value: "value1", for: "key1")
            .with(value: 123, for: "key2")

        XCTAssertEqual(ctx.get(String.self, for: "key1"), "value1")
        XCTAssertEqual(ctx.get(Int.self, for: "key2"), 123)
    }

    // TEST013: Confirm getRequired succeeds for present keys and returns an error for missing keys
    func test_013_required_values() {
        let ctx = DryContext().with(value: 42, for: "exists")

        XCTAssertEqual(try? ctx.getRequired(Int.self, for: "exists"), 42)
        XCTAssertThrowsError(try ctx.getRequired(Int.self, for: "missing"))
    }

    // TEST014: Merge two DryContexts and verify values from both are accessible in the target
    func test_014_context_merge() {
        let ctx1 = DryContext().with(value: 1, for: "a")
        let ctx2 = DryContext().with(value: 2, for: "b")
        ctx1.merge(ctx2)
        XCTAssertEqual(ctx1.get(Int.self, for: "a"), 1)
        XCTAssertEqual(ctx1.get(Int.self, for: "b"), 2)
    }

    // TEST015: Verify getRequired returns a Type mismatch error when the stored type doesn't match
    func test_015_dry_context_type_mismatch_error() {
        let ctx = DryContext()
            .with(value: "not_a_number", for: "count")
            .with(value: 123, for: "flag")

        // String value, expecting Int
        XCTAssertThrowsError(try ctx.getRequired(Int.self, for: "count")) { err in
            let msg = (err as! OpError).description
            XCTAssertTrue(msg.contains("Type mismatch"))
            XCTAssertTrue(msg.contains("Int"))
        }

        // Missing key gives "not found"
        XCTAssertThrowsError(try ctx.getRequired(Int.self, for: "missing")) { err in
            let msg = (err as! OpError).description
            XCTAssertTrue(msg.contains("not found"))
            XCTAssertFalse(msg.contains("Type mismatch"))
        }
    }

    // TEST017: Set and clear abort flags on DryContext and verify isAborted and abortReason reflect state
    func test_017_control_flags() {
        let ctx = DryContext()

        XCTAssertFalse(ctx.isAborted)
        XCTAssertNil(ctx.abortReason)

        ctx.setAbort(reason: "Test abort reason")
        XCTAssertTrue(ctx.isAborted)
        XCTAssertEqual(ctx.abortReason, "Test abort reason")

        ctx.clearControlFlags()
        XCTAssertFalse(ctx.isAborted)
        XCTAssertNil(ctx.abortReason)
    }

    // TEST018: Merge contexts with abort flags and confirm the target inherits the abort state correctly
    func test_018_control_flags_merge() {
        let ctx1 = DryContext()
        let ctx2 = DryContext()
        ctx2.setAbort(reason: "Merged abort")
        ctx1.merge(ctx2)

        XCTAssertTrue(ctx1.isAborted)
        XCTAssertEqual(ctx1.abortReason, "Merged abort")

        // merge doesn't override existing abort
        let ctx3 = DryContext()
        ctx3.setAbort(reason: "Original abort")
        let ctx4 = DryContext()
        ctx4.setAbort(reason: "New abort")
        ctx3.merge(ctx4)
        XCTAssertEqual(ctx3.abortReason, "Original abort")
    }

    // TEST019: Verify getOrInsert inserts when missing and returns existing without calling factory
    func test_019_get_or_insert_with() throws {
        let ctx = DryContext()

        let value = try ctx.getOrInsert(for: "count") { 42 }
        XCTAssertEqual(value, 42)
        XCTAssertEqual(ctx.get(Int.self, for: "count"), 42)

        var factoryCalled = false
        let existing = try ctx.getOrInsert(for: "count") { () -> Int in
            factoryCalled = true
            return 100
        }
        XCTAssertEqual(existing, 42)
        XCTAssertFalse(factoryCalled)
    }

    // TEST020: Verify getOrCompute computes and stores a value using context data
    func test_020_get_or_compute_with() throws {
        let ctx = DryContext()
        ctx.insert(8000, for: "base_port")
        ctx.insert("test_app", for: "app_name")

        let computedUrl = try ctx.getOrCompute(for: "service_url") { ctx, _ -> String in
            let basePort = ctx.get(Int.self, for: "base_port") ?? 3000
            let appName = ctx.get(String.self, for: "app_name") ?? "default"
            ctx.insert(basePort + 80, for: "computed_port")
            return "http://\(appName):\(basePort + 80)"
        }

        XCTAssertEqual(computedUrl, "http://test_app:8080")
        XCTAssertEqual(ctx.get(String.self, for: "service_url"), "http://test_app:8080")
        XCTAssertEqual(ctx.get(Int.self, for: "computed_port"), 8080)

        var computerCalled = false
        let existing = try ctx.getOrCompute(for: "service_url") { _, _ -> String in
            computerCalled = true
            return "should_not_be_called"
        }
        XCTAssertEqual(existing, "http://test_app:8080")
        XCTAssertFalse(computerCalled)
    }

    // TEST098: Merge two DryContexts where keys overlap and verify the merging context's values win
    func test_098_dry_context_merge_overwrites_keys() {
        let ctx1 = DryContext().with(value: 1, for: "shared").with(value: 10, for: "only_in_1")
        let ctx2 = DryContext().with(value: 2, for: "shared").with(value: 20, for: "only_in_2")
        ctx1.merge(ctx2)
        XCTAssertEqual(ctx1.get(Int.self, for: "shared"), 2)
        XCTAssertEqual(ctx1.get(Int.self, for: "only_in_1"), 10)
        XCTAssertEqual(ctx1.get(Int.self, for: "only_in_2"), 20)
    }

    // TEST100: Serialize and deserialize a DryContext JSON representation and verify all values survive
    func test_100_dry_context_serde_roundtrip() throws {
        let original = DryContext()
            .with(value: "alice", for: "name")
            .with(value: 42, for: "count")
            .with(value: true, for: "flag")

        // Simulate roundtrip by copying values via JSON
        let values = original.values
        guard let data = try? JSONSerialization.data(withJSONObject: values),
              let restored = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            XCTFail("serialization failed")
            return
        }
        let ctx = DryContext()
        for (k, v) in restored {
            if let n = v as? NSNumber {
                if n === (true as AnyObject) || n === (false as AnyObject) {
                    ctx.insert(n.boolValue, for: k)
                } else if n.doubleValue == n.doubleValue.rounded() {
                    ctx.insert(n.intValue, for: k)
                } else {
                    ctx.insert(n.doubleValue, for: k)
                }
            } else if let s = v as? String {
                ctx.insert(s, for: k)
            }
        }

        XCTAssertEqual(ctx.get(String.self, for: "name"), "alice")
        XCTAssertEqual(ctx.get(Int.self, for: "count"), 42)
        XCTAssertEqual(ctx.get(Bool.self, for: "flag"), true)
    }

    // TEST101: Clone a DryContext and verify the clone is independent (mutations don't propagate)
    func test_101_dry_context_clone_is_independent() {
        let original = DryContext().with(value: 1, for: "x")
        let cloned = original.copy()
        cloned.insert(99, for: "x")
        XCTAssertEqual(original.get(Int.self, for: "x"), 1)
        XCTAssertEqual(cloned.get(Int.self, for: "x"), 99)
    }

    // TEST102: Verify DryContext::keys() returns all inserted keys
    func test_102_dry_context_keys() {
        let ctx = DryContext()
            .with(value: 1, for: "alpha")
            .with(value: 2, for: "beta")
            .with(value: 3, for: "gamma")
        let keys = ctx.keys.sorted()
        XCTAssertEqual(keys, ["alpha", "beta", "gamma"])
    }
}
