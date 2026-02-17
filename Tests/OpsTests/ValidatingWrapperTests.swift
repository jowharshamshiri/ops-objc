import XCTest
@testable import Ops

final class ValidatingWrapperTests: XCTestCase {

    struct TestOutput: Encodable {
        let value: Int
    }

    struct ValidatedOp: Op {
        typealias Output = TestOutput
        func perform(dry: DryContext, wet: WetContext) async throws -> TestOutput {
            let value = try dry.getRequired(Int.self, for: "value")
            return TestOutput(value: value)
        }
        func metadata() -> OpMetadata {
            OpMetadata.builder("ValidatedOp")
                .description("Op with schema validation")
                .inputSchema([
                    "type": "object",
                    "properties": ["value": ["type": "integer", "minimum": 0, "maximum": 100]],
                    "required": ["value"]
                ])
                .outputSchema([
                    "type": "object",
                    "properties": ["value": ["type": "integer"]],
                    "required": ["value"]
                ])
                .build()
        }
    }

    // TEST038: Run ValidatingWrapper with a valid input and verify the op executes and returns the result
    func test_038_valid_input_output() async throws {
        let validator = ValidatingWrapper(op: AnyOp(ValidatedOp()))
        let dry = DryContext()
        dry.insert(42, for: "value")
        let wet = WetContext()
        let result = try await validator.perform(dry: dry, wet: wet)
        XCTAssertEqual(result.value, 42)
    }

    // TEST039: Run ValidatingWrapper without a required input field and verify a Context validation error
    func test_039_invalid_input_missing_required() async {
        let validator = ValidatingWrapper(op: AnyOp(ValidatedOp()))
        let dry = DryContext() // missing "value"
        let wet = WetContext()
        do {
            _ = try await validator.perform(dry: dry, wet: wet)
            XCTFail("Expected error")
        } catch OpError.context(let msg) {
            XCTAssertTrue(msg.contains("Input validation failed"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // TEST040: Run ValidatingWrapper with an input exceeding the schema maximum and verify a validation error
    func test_040_invalid_input_out_of_range() async {
        let validator = ValidatingWrapper(op: AnyOp(ValidatedOp()))
        let dry = DryContext()
        dry.insert(150, for: "value") // exceeds maximum of 100
        let wet = WetContext()
        do {
            _ = try await validator.perform(dry: dry, wet: wet)
            XCTFail("Expected error")
        } catch OpError.context(let msg) {
            XCTAssertTrue(msg.contains("maximum"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // TEST041: Use ValidatingWrapper.inputOnly and confirm input is validated while output is not
    func test_041_input_only_validation() async throws {
        struct NoOutputSchemaOp: Op {
            typealias Output = Int
            func perform(dry: DryContext, wet: WetContext) async throws -> Int {
                try dry.getRequired(Int.self, for: "value")
            }
            func metadata() -> OpMetadata {
                OpMetadata.builder("NoOutputSchemaOp")
                    .inputSchema([
                        "type": "object",
                        "properties": ["value": ["type": "integer"]],
                        "required": ["value"]
                    ])
                    .build()
            }
        }
        let validator = ValidatingWrapper.inputOnly(op: AnyOp(NoOutputSchemaOp()))
        let dry = DryContext()
        dry.insert(42, for: "value")
        let wet = WetContext()
        let result = try await validator.perform(dry: dry, wet: wet)
        XCTAssertEqual(result, 42)
    }

    // TEST042: Use ValidatingWrapper.outputOnly and confirm output is validated while input is not
    func test_042_output_only_validation() async throws {
        struct NoInputSchemaOp: Op {
            typealias Output = TestOutput
            func perform(dry: DryContext, wet: WetContext) async throws -> TestOutput {
                TestOutput(value: 99)
            }
            func metadata() -> OpMetadata {
                OpMetadata.builder("NoInputSchemaOp")
                    .outputSchema([
                        "type": "object",
                        "properties": ["value": ["type": "integer", "maximum": 100]],
                        "required": ["value"]
                    ])
                    .build()
            }
        }
        let validator = ValidatingWrapper.outputOnly(op: AnyOp(NoInputSchemaOp()))
        let dry = DryContext()
        let wet = WetContext()
        let result = try await validator.perform(dry: dry, wet: wet)
        XCTAssertEqual(result.value, 99)
    }

    // TEST043: Wrap an op with no schemas in ValidatingWrapper and confirm it still succeeds
    func test_043_no_schema_validation() async throws {
        struct NoSchemaOp: Op {
            typealias Output = Int
            func perform(dry: DryContext, wet: WetContext) async throws -> Int { 123 }
            func metadata() -> OpMetadata { OpMetadata.builder("NoSchemaOp").build() }
        }
        let validator = ValidatingWrapper(op: AnyOp(NoSchemaOp()))
        let dry = DryContext()
        let wet = WetContext()
        let result = try await validator.perform(dry: dry, wet: wet)
        XCTAssertEqual(result, 123)
    }

    // TEST044: Verify ValidatingWrapper.metadata() delegates to the inner op's metadata unchanged
    func test_044_metadata_transparency() {
        let validator = ValidatingWrapper(op: AnyOp(ValidatedOp()))
        let meta = validator.metadata()
        XCTAssertEqual(meta.name, "ValidatedOp")
        XCTAssertEqual(meta.description, "Op with schema validation")
        XCTAssertNotNil(meta.inputSchema)
        XCTAssertNotNil(meta.outputSchema)
    }

    // TEST045: Verify ValidatingWrapper checks reference_schema and rejects when required refs are missing
    func test_045_reference_validation() async throws {
        struct ServiceRequiringOp: Op {
            typealias Output = String
            func perform(dry: DryContext, wet: WetContext) async throws -> String {
                let service = try wet.getRequired(String.self, for: "database")
                return "Used service: \(service)"
            }
            func metadata() -> OpMetadata {
                OpMetadata.builder("ServiceRequiringOp")
                    .referenceSchema([
                        "type": "object",
                        "required": ["database", "cache"],
                        "properties": [
                            "database": ["type": "string"],
                            "cache": ["type": "string"]
                        ]
                    ])
                    .build()
            }
        }
        let validator = ValidatingWrapper(op: AnyOp(ServiceRequiringOp()))
        let dry = DryContext()
        let wet = WetContext()

        // Missing required references
        do {
            _ = try await validator.perform(dry: dry, wet: wet)
            XCTFail("Expected error")
        } catch OpError.context(let msg) {
            XCTAssertTrue(msg.contains("Required reference 'database' not found"))
        }

        // Add one reference but not all
        wet.insertRef("postgresql", for: "database")
        do {
            _ = try await validator.perform(dry: dry, wet: wet)
            XCTFail("Expected error")
        } catch OpError.context(let msg) {
            XCTAssertTrue(msg.contains("Required reference 'cache' not found"))
        }

        // Add all required references
        wet.insertRef("redis", for: "cache")
        let result = try await validator.perform(dry: dry, wet: wet)
        XCTAssertEqual(result, "Used service: postgresql")
    }

    // TEST046: Wrap an op with no reference schema in ValidatingWrapper and confirm it succeeds
    func test_046_no_reference_schema() async throws {
        struct NoRefSchemaOp: Op {
            typealias Output = Int
            func perform(dry: DryContext, wet: WetContext) async throws -> Int { 456 }
            func metadata() -> OpMetadata { OpMetadata.builder("NoRefSchemaOp").build() }
        }
        let validator = ValidatingWrapper(op: AnyOp(NoRefSchemaOp()))
        let dry = DryContext()
        let wet = WetContext()
        let result = try await validator.perform(dry: dry, wet: wet)
        XCTAssertEqual(result, 456)
    }

    // TEST112: Verify ValidatingWrapper.outputOnly validates references even when input validation is disabled
    func test_112_output_only_still_validates_references() async throws {
        struct RefRequiringOp: Op {
            typealias Output = Int
            func perform(dry: DryContext, wet: WetContext) async throws -> Int { 42 }
            func metadata() -> OpMetadata {
                OpMetadata.builder("RefRequiringOp")
                    .referenceSchema([
                        "type": "object",
                        "required": ["database"],
                        "properties": ["database": ["type": "string"]]
                    ])
                    .build()
            }
        }
        let validator = ValidatingWrapper.outputOnly(op: AnyOp(RefRequiringOp()))
        let dry = DryContext()
        let wet = WetContext()

        // Missing required reference — must be rejected even though input validation is off
        do {
            _ = try await validator.perform(dry: dry, wet: wet)
            XCTFail("output_only must still validate references")
        } catch OpError.context(let msg) {
            XCTAssertTrue(msg.contains("database"))
        }

        // With the reference present — must succeed
        wet.insertRef("postgres://localhost", for: "database")
        let result = try await validator.perform(dry: dry, wet: wet)
        XCTAssertEqual(result, 42)
    }
}
