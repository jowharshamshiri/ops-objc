import XCTest
@testable import Ops

final class BatchMetadataTests: XCTestCase {

    // TEST047: Build BatchMetadata from producer/consumer ops and verify only external inputs are required
    func test_047_batch_metadata_with_data_flow() {
        struct ProducerOp: Op {
            typealias Output = String
            func perform(dry: DryContext, wet: WetContext) async throws -> String {
                let input = try dry.getRequired(String.self, for: "initial_input")
                return "produced_\(input)"
            }
            func metadata() -> OpMetadata {
                OpMetadata.builder("ProducerOp")
                    .inputSchema([
                        "type": "object",
                        "properties": ["initial_input": ["type": "string"]],
                        "required": ["initial_input"]
                    ])
                    .outputSchema([
                        "type": "object",
                        "properties": ["produced_value": ["type": "string"]]
                    ])
                    .build()
            }
        }

        struct ConsumerOp: Op {
            typealias Output = String
            func perform(dry: DryContext, wet: WetContext) async throws -> String {
                let value = try dry.getRequired(String.self, for: "produced_value")
                return "consumed_\(value)"
            }
            func metadata() -> OpMetadata {
                OpMetadata.builder("ConsumerOp")
                    .inputSchema([
                        "type": "object",
                        "properties": ["produced_value": ["type": "string"]],
                        "required": ["produced_value"]
                    ])
                    .outputSchema([
                        "type": "object",
                        "properties": ["final_result": ["type": "string"]]
                    ])
                    .build()
            }
        }

        let ops = [AnyOp(ProducerOp()), AnyOp(ConsumerOp())]
        let builder = BatchMetadataBuilder(ops: ops)
        let metadata = builder.build()

        if let inputSchema = metadata.inputSchema,
           let required = inputSchema["required"] as? [String] {
            XCTAssertEqual(required.count, 1)
            XCTAssertTrue(required.contains("initial_input"))
        } else {
            XCTFail("Expected input schema with required fields")
        }
    }

    // TEST048: Build BatchMetadata from two ops with different reference schemas and verify union of required refs
    func test_048_reference_schema_merging() {
        struct ServiceAOp: Op {
            typealias Output = Void
            func perform(dry: DryContext, wet: WetContext) async throws {}
            func metadata() -> OpMetadata {
                OpMetadata.builder("ServiceAOp")
                    .referenceSchema([
                        "type": "object",
                        "properties": ["service_a": ["type": "ServiceA"]],
                        "required": ["service_a"]
                    ])
                    .build()
            }
        }

        struct ServiceBOp: Op {
            typealias Output = Void
            func perform(dry: DryContext, wet: WetContext) async throws {}
            func metadata() -> OpMetadata {
                OpMetadata.builder("ServiceBOp")
                    .referenceSchema([
                        "type": "object",
                        "properties": ["service_b": ["type": "ServiceB"]],
                        "required": ["service_b"]
                    ])
                    .build()
            }
        }

        let ops = [AnyOp(ServiceAOp()), AnyOp(ServiceBOp())]
        let builder = BatchMetadataBuilder(ops: ops)
        let metadata = builder.build()

        if let refSchema = metadata.referenceSchema,
           let required = refSchema["required"] as? [String] {
            XCTAssertEqual(required.count, 2)
            XCTAssertTrue(required.contains("service_a"))
            XCTAssertTrue(required.contains("service_b"))
        } else {
            XCTFail("Expected reference schema with required refs")
        }
    }
}
