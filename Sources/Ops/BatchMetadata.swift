import Foundation

/// Analyzes and constructs metadata for batch operations by understanding data flow.
public struct BatchMetadataBuilder<T: Sendable> {
    private let opsMetadata: [OpMetadata]

    public init(ops: [AnyOp<T>]) {
        opsMetadata = ops.map { $0.metadata() }
    }

    public func build() -> OpMetadata {
        let (inputSchema, _) = analyzeInputRequirements()
        let referenceSchema = mergeReferenceSchemas()
        let outputSchema: [String: Any] = [
            "type": "array",
            "items": ["type": "object", "description": "Output from individual ops in the batch"],
            "minItems": opsMetadata.count,
            "maxItems": opsMetadata.count
        ]

        return OpMetadata.builder("BatchOp")
            .description("Batch of \(opsMetadata.count) operations with data flow analysis")
            .inputSchema(inputSchema)
            .referenceSchema(referenceSchema)
            .outputSchema(outputSchema)
            .build()
    }

    private func analyzeInputRequirements() -> ([String: Any], [Int: Set<String>]) {
        var requiredInputs: Set<String> = []
        var availableOutputs: Set<String> = []
        var outputsByIndex: [Int: Set<String>] = [:]

        for (index, meta) in opsMetadata.enumerated() {
            if let schema = meta.inputSchema,
               let required = schema["required"] as? [String] {
                for field in required {
                    if !availableOutputs.contains(field) {
                        requiredInputs.insert(field)
                    }
                }
            }

            let opOutputs = extractOutputFields(from: meta.outputSchema)
            outputsByIndex[index] = opOutputs
            availableOutputs.formUnion(opOutputs)
        }

        let inputSchema = buildInputSchema(requiredFields: requiredInputs)
        return (inputSchema, outputsByIndex)
    }

    private func extractOutputFields(from schema: [String: Any]?) -> Set<String> {
        guard let schema = schema else { return [] }
        var fields: Set<String> = []
        if let properties = schema["properties"] as? [String: Any] {
            fields.formUnion(properties.keys)
        } else if let type_ = schema["type"] as? String, type_ == "string" {
            fields.insert("result")
        }
        return fields
    }

    private func buildInputSchema(requiredFields: Set<String>) -> [String: Any] {
        var properties: [String: Any] = [:]
        var required: [String] = []

        for meta in opsMetadata {
            guard let schema = meta.inputSchema,
                  let schemaProps = schema["properties"] as? [String: Any] else { continue }
            for (fieldName, fieldSchema) in schemaProps {
                if requiredFields.contains(fieldName) && properties[fieldName] == nil {
                    properties[fieldName] = fieldSchema
                    required.append(fieldName)
                }
            }
        }

        return [
            "type": "object",
            "properties": properties,
            "required": required,
            "additionalProperties": false
        ]
    }

    private func mergeReferenceSchemas() -> [String: Any] {
        var allProperties: [String: Any] = [:]
        var allRequired: Set<String> = []

        for meta in opsMetadata {
            guard let schema = meta.referenceSchema else { continue }
            if let properties = schema["properties"] as? [String: Any] {
                for (key, value) in properties {
                    if allProperties[key] == nil {
                        allProperties[key] = value
                    }
                }
            }
            if let required = schema["required"] as? [String] {
                allRequired.formUnion(required)
            }
        }

        return [
            "type": "object",
            "properties": allProperties,
            "required": Array(allRequired),
            "additionalProperties": false
        ]
    }
}
