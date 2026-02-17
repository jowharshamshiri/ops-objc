import XCTest
@testable import Ops

final class OpMetadataTests: XCTestCase {

    // TEST021: Build OpMetadata with name, description, and schemas and verify all fields are populated
    func test_021_metadata_builder() {
        let metadata = OpMetadata.builder("TestOp")
            .description("A test operation")
            .inputSchema([
                "type": "object",
                "properties": ["name": ["type": "string"]],
                "required": ["name"]
            ])
            .outputSchema(["type": "string"])
            .build()

        XCTAssertEqual(metadata.name, "TestOp")
        XCTAssertEqual(metadata.description, "A test operation")
        XCTAssertNotNil(metadata.inputSchema)
        XCTAssertNotNil(metadata.outputSchema)
    }

    // TEST022: Construct a TriggerFuse with data and verify the trigger name and dry context values
    func test_022_trigger_fuse() {
        let fuse = TriggerFuse(triggerName: "ProcessImage")
            .withData("/tmp/test.jpg", for: "image_path")
            .withData(800, for: "width")

        XCTAssertEqual(fuse.triggerName, "ProcessImage")
        XCTAssertEqual(fuse.dryContext.get(String.self, for: "image_path"), "/tmp/test.jpg")
        XCTAssertEqual(fuse.dryContext.get(Int.self, for: "width"), 800)
    }

    // TEST023: Validate a DryContext against an input schema and confirm valid/invalid reports
    func test_023_basic_validation() throws {
        let metadata = OpMetadata.builder("TestOp")
            .inputSchema(["type": "object", "required": ["name"]])
            .build()

        let validCtx = DryContext().with(value: "test", for: "name")
        let report = try metadata.validateDryContext(validCtx)
        XCTAssertTrue(report.isValid)

        let emptyCtx = DryContext()
        let report2 = try metadata.validateDryContext(emptyCtx)
        XCTAssertFalse(report2.isValid)
        XCTAssertEqual(report2.errors.count, 1)
    }
}
