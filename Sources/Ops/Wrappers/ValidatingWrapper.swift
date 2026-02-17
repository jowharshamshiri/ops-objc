import Foundation

/// Wraps an op with JSON Schema validation for input, output, and references.
public final class ValidatingWrapper<T: Sendable>: Sendable {
    private let wrappedOp: AnyOp<T>
    private let validateInput: Bool
    private let validateOutput: Bool

    public init(op: AnyOp<T>, validateInput: Bool = true, validateOutput: Bool = true) {
        self.wrappedOp = op
        self.validateInput = validateInput
        self.validateOutput = validateOutput
    }

    public static func inputOnly(op: AnyOp<T>) -> ValidatingWrapper<T> {
        ValidatingWrapper(op: op, validateInput: true, validateOutput: false)
    }

    public static func outputOnly(op: AnyOp<T>) -> ValidatingWrapper<T> {
        ValidatingWrapper(op: op, validateInput: false, validateOutput: true)
    }

    private func validateInputSchema(dry: DryContext, metadata: OpMetadata) throws {
        guard validateInput, let schema = metadata.inputSchema else { return }
        try JSONSchemaValidator.validate(dry.values, against: schema, opName: metadata.name, phase: "Input")
    }

    private func validateReferenceSchema(wet: WetContext, metadata: OpMetadata) throws {
        // References always validated when reference_schema is present
        guard let schema = metadata.referenceSchema else { return }
        if let required = schema["required"] as? [String] {
            for ref in required {
                if !wet.contains(ref) {
                    throw OpError.context(
                        "Required reference '\(ref)' not found in WetContext for op '\(metadata.name)'"
                    )
                }
            }
        }
    }

    private func validateOutputSchema(output: T, metadata: OpMetadata) throws where T: Encodable {
        guard validateOutput, let schema = metadata.outputSchema else { return }
        // Encode output to JSON-compatible type for validation
        guard let data = try? JSONEncoder().encode(output),
              let jsonObj = try? JSONSerialization.jsonObject(with: data) else {
            throw OpError.context("Failed to serialize output for validation")
        }
        let dict: [String: Any]
        if let d = jsonObj as? [String: Any] {
            dict = d
        } else {
            // Wrap scalar in a container for schema validation
            dict = ["value": jsonObj]
        }
        try JSONSchemaValidator.validate(dict, against: schema, opName: metadata.name, phase: "Output")
    }

    public func perform(dry: DryContext, wet: WetContext) async throws -> T {
        let metadata = wrappedOp.metadata()
        try validateInputSchema(dry: dry, metadata: metadata)
        try validateReferenceSchema(wet: wet, metadata: metadata)
        let result = try await wrappedOp.perform(dry: dry, wet: wet)
        if let encodable = result as? any Encodable {
            // If T is Encodable, validate output
            try validateOutputIfEncodable(encodable, metadata: metadata)
        }
        return result
    }

    private func validateOutputIfEncodable(_ output: any Encodable, metadata: OpMetadata) throws {
        guard validateOutput, let schema = metadata.outputSchema else { return }
        guard let data = try? JSONEncoder().encode(output),
              let jsonObj = try? JSONSerialization.jsonObject(with: data) else {
            throw OpError.context("Failed to serialize output for validation")
        }
        let dict: [String: Any]
        if let d = jsonObj as? [String: Any] {
            dict = d
        } else {
            dict = ["value": jsonObj]
        }
        try JSONSchemaValidator.validate(dict, against: schema, opName: metadata.name, phase: "Output")
    }

    public func metadata() -> OpMetadata {
        wrappedOp.metadata()
    }
}

// MARK: - Simple JSON Schema validator

enum JSONSchemaValidator {
    static func validate(
        _ value: [String: Any],
        against schema: [String: Any],
        opName: String,
        phase: String
    ) throws {
        var errorMessages: [String] = []

        // Check required fields
        if let required = schema["required"] as? [String] {
            for field in required {
                if value[field] == nil {
                    errorMessages.append("/\(field): '\(field)' is a required property")
                }
            }
        }

        // Check property constraints
        if let properties = schema["properties"] as? [String: Any] {
            for (field, fieldSchema) in properties {
                guard let fieldSchema = fieldSchema as? [String: Any],
                      let rawValue = value[field] else { continue }
                if let errors = validateFieldConstraints(rawValue, schema: fieldSchema, field: field) {
                    errorMessages.append(contentsOf: errors)
                }
            }
        }

        if !errorMessages.isEmpty {
            throw OpError.context(
                "\(phase) validation failed for \(opName): \(errorMessages.joined(separator: ", "))"
            )
        }
    }

    private static func validateFieldConstraints(_ value: Any, schema: [String: Any], field: String) -> [String]? {
        var errors: [String] = []

        if let typeStr = schema["type"] as? String {
            switch typeStr {
            case "integer":
                if let num = value as? NSNumber {
                    if let maximum = (schema["maximum"] as? NSNumber)?.doubleValue, num.doubleValue > maximum {
                        errors.append("/\(field): \(num) is greater than the maximum of \(maximum)")
                    }
                    if let minimum = (schema["minimum"] as? NSNumber)?.doubleValue, num.doubleValue < minimum {
                        errors.append("/\(field): \(num) is less than the minimum of \(minimum)")
                    }
                }
            case "string":
                break
            case "boolean":
                break
            case "number":
                break
            default:
                break
            }
        }

        return errors.isEmpty ? nil : errors
    }
}
