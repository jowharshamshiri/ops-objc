import Foundation

/// Metadata describing an op's requirements and schemas.
public struct OpMetadata: Sendable {
    public let name: String
    public let inputSchema: [String: Any]?
    public let referenceSchema: [String: Any]?
    public let outputSchema: [String: Any]?
    public let description: String?

    public static func builder(_ name: String) -> OpMetadataBuilder {
        OpMetadataBuilder(name: name)
    }
}

public final class OpMetadataBuilder: Sendable {
    private let name: String
    private var inputSchema: [String: Any]?
    private var referenceSchema: [String: Any]?
    private var outputSchema: [String: Any]?
    private var description: String?

    public init(name: String) {
        self.name = name
    }

    public func inputSchema(_ schema: [String: Any]) -> OpMetadataBuilder {
        self.inputSchema = schema
        return self
    }

    public func referenceSchema(_ schema: [String: Any]) -> OpMetadataBuilder {
        self.referenceSchema = schema
        return self
    }

    public func outputSchema(_ schema: [String: Any]) -> OpMetadataBuilder {
        self.outputSchema = schema
        return self
    }

    public func description(_ desc: String) -> OpMetadataBuilder {
        self.description = desc
        return self
    }

    public func build() -> OpMetadata {
        OpMetadata(
            name: name,
            inputSchema: inputSchema,
            referenceSchema: referenceSchema,
            outputSchema: outputSchema,
            description: description
        )
    }
}

// MARK: - Validation

public struct ValidationError: Sendable {
    public let field: String
    public let message: String
}

public struct ValidationWarning: Sendable {
    public let field: String
    public let message: String
}

public struct ValidationReport: Sendable {
    public let isValid: Bool
    public let errors: [ValidationError]
    public let warnings: [ValidationWarning]

    public static func success() -> ValidationReport {
        ValidationReport(isValid: true, errors: [], warnings: [])
    }

    public var isFullyValid: Bool {
        isValid && warnings.isEmpty
    }
}

// MARK: - Metadata validation methods

extension OpMetadata {
    public func validateDryContext(_ ctx: DryContext) throws -> ValidationReport {
        guard let schema = inputSchema else { return .success() }
        return validateAgainstSchema(ctx.values, schema: schema)
    }

    public func validateWetContext(_ ctx: WetContext) throws -> ValidationReport {
        guard let schema = referenceSchema else { return .success() }
        var contextKeys: [String: Any] = [:]
        for key in ctx.keys {
            contextKeys[key] = "present"
        }
        return validateReferenceSchema(contextKeys, schema: schema)
    }

    public func validateContexts(dry: DryContext, wet: WetContext) throws -> ValidationReport {
        let dryReport = try validateDryContext(dry)
        let wetReport = try validateWetContext(wet)
        return ValidationReport(
            isValid: dryReport.isValid && wetReport.isValid,
            errors: dryReport.errors + wetReport.errors,
            warnings: dryReport.warnings + wetReport.warnings
        )
    }
}

private func validateAgainstSchema(_ value: [String: Any], schema: [String: Any]) -> ValidationReport {
    var errors: [ValidationError] = []
    if let required = schema["required"] as? [String] {
        for field in required {
            if value[field] == nil {
                errors.append(ValidationError(field: field, message: "Required field '\(field)' is missing"))
            }
        }
    }
    return ValidationReport(isValid: errors.isEmpty, errors: errors, warnings: [])
}

private func validateReferenceSchema(_ value: [String: Any], schema: [String: Any]) -> ValidationReport {
    var errors: [ValidationError] = []
    if let required = schema["required"] as? [String] {
        for field in required {
            if value[field] == nil {
                errors.append(ValidationError(field: field, message: "Required reference '\(field)' is missing"))
            }
        }
    }
    return ValidationReport(isValid: errors.isEmpty, errors: errors, warnings: [])
}

// MARK: - TriggerFuse

public final class TriggerFuse: Sendable {
    public let id: String
    public let triggerName: String
    public let dryContext: DryContext
    public let createdAt: Date
    public let metadata: OpMetadata?

    public init(triggerName: String) {
        self.id = UUID().uuidString
        self.triggerName = triggerName
        self.dryContext = DryContext()
        self.createdAt = Date()
        self.metadata = nil
    }

    private init(
        id: String,
        triggerName: String,
        dryContext: DryContext,
        createdAt: Date,
        metadata: OpMetadata?
    ) {
        self.id = id
        self.triggerName = triggerName
        self.dryContext = dryContext
        self.createdAt = createdAt
        self.metadata = metadata
    }

    public func withData<T: Encodable>(_ value: T, for key: String) -> TriggerFuse {
        let newCtx = dryContext.copy()
        newCtx.insert(value, for: key)
        return TriggerFuse(id: id, triggerName: triggerName, dryContext: newCtx, createdAt: createdAt, metadata: metadata)
    }

    public func withMetadata(_ metadata: OpMetadata) -> TriggerFuse {
        TriggerFuse(id: id, triggerName: triggerName, dryContext: dryContext, createdAt: createdAt, metadata: metadata)
    }

    public func validateAndGetDryContext() throws -> DryContext {
        if let metadata = metadata {
            let report = try metadata.validateDryContext(dryContext)
            if !report.isValid {
                throw OpError.context("Invalid dry context: \(report.errors.map(\.message).joined(separator: ", "))")
            }
        }
        return dryContext.copy()
    }
}
