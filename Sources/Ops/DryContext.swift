import Foundation

/// Control flow state for dry context.
public struct ControlFlags: Sendable {
    public var aborted: Bool = false
    public var abortReason: String? = nil
}

/// DryContext contains only serializable (JSON-compatible) data values.
/// Thread-safe via a lock.
public final class DryContext: @unchecked Sendable {
    private let lock = NSLock()
    private var _values: [String: Any] = [:]
    private var _controlFlags: ControlFlags = ControlFlags()

    public init() {}

    // MARK: - Builder

    public func with<T: Encodable>(value: T, for key: String) -> DryContext {
        insert(value, for: key)
        return self
    }

    // MARK: - Insert / Get

    public func insert<T: Encodable>(_ value: T, for key: String) {
        guard let jsonObj = toJSONCompatible(value) else {
            preconditionFailure("DryContext.insert: failed to serialize value for key '\(key)'")
        }
        lock.lock()
        defer { lock.unlock() }
        _values[key] = jsonObj
    }

    public func get<T: Decodable>(_ type: T.Type = T.self, for key: String) -> T? {
        lock.lock()
        let raw = _values[key]
        lock.unlock()
        guard let raw = raw else { return nil }
        return fromJSONCompatible(raw, as: type)
    }

    public func getRequired<T: Decodable>(_ type: T.Type = T.self, for key: String) throws -> T {
        lock.lock()
        let raw = _values[key]
        lock.unlock()
        guard let raw = raw else {
            throw OpError.context("Required dry context key '\(key)' not found")
        }
        guard let value = fromJSONCompatible(raw, as: type) else {
            let actualType = jsonTypeName(raw)
            let expectedType = String(describing: type)
            throw OpError.context(
                "Type mismatch for dry context key '\(key)': expected type '\(expectedType)', but found '\(actualType)' value: \(raw)"
            )
        }
        return value
    }

    public func contains(_ key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return _values[key] != nil
    }

    public var keys: [String] {
        lock.lock()
        defer { lock.unlock() }
        return Array(_values.keys)
    }

    public var values: [String: Any] {
        lock.lock()
        defer { lock.unlock() }
        return _values
    }

    // MARK: - get_or_insert_with equivalent

    public func getOrInsert<T: Codable>(for key: String, factory: () -> T) throws -> T {
        if let existing = get(T.self, for: key) {
            return existing
        }
        let newValue = factory()
        insert(newValue, for: key)
        return newValue
    }

    public func getOrCompute<T: Codable>(for key: String, computer: (DryContext, String) -> T) throws -> T {
        if let existing = get(T.self, for: key) {
            return existing
        }
        let newValue = computer(self, key)
        insert(newValue, for: key)
        return newValue
    }

    public func ensure<T: Codable>(
        for key: String,
        wet: WetContext,
        factory: @Sendable (DryContext, WetContext, String) async throws -> T
    ) async throws -> T {
        if let existing = get(T.self, for: key) {
            return existing
        }
        let newValue = try await factory(self, wet, key)
        insert(newValue, for: key)
        return newValue
    }

    // MARK: - Merge

    public func merge(_ other: DryContext) {
        let otherValues = other.values
        let otherFlags = other.controlFlags
        lock.lock()
        defer { lock.unlock() }
        for (k, v) in otherValues {
            _values[k] = v
        }
        if otherFlags.aborted && !_controlFlags.aborted {
            _controlFlags.aborted = true
            _controlFlags.abortReason = otherFlags.abortReason
        }
    }

    // MARK: - Control Flags

    public func setAbort(reason: String? = nil) {
        lock.lock()
        defer { lock.unlock() }
        _controlFlags.aborted = true
        _controlFlags.abortReason = reason
    }

    public var isAborted: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _controlFlags.aborted
    }

    public var abortReason: String? {
        lock.lock()
        defer { lock.unlock() }
        return _controlFlags.abortReason
    }

    public func clearControlFlags() {
        lock.lock()
        defer { lock.unlock() }
        _controlFlags = ControlFlags()
    }

    var controlFlags: ControlFlags {
        lock.lock()
        defer { lock.unlock() }
        return _controlFlags
    }

    // MARK: - Copy

    public func copy() -> DryContext {
        let c = DryContext()
        lock.lock()
        c._values = _values
        c._controlFlags = _controlFlags
        lock.unlock()
        return c
    }

    // MARK: - JSON serialization helpers

    private func toJSONCompatible<T: Encodable>(_ value: T) -> Any? {
        guard let data = try? JSONEncoder().encode(value),
              let obj = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }
        return obj
    }

    private func fromJSONCompatible<T: Decodable>(_ raw: Any, as type: T.Type) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: raw, options: []) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func jsonTypeName(_ value: Any) -> String {
        if value is NSNull { return "null" }
        if value is Bool { return "boolean" }
        if value is NSNumber { return "number" }
        if value is String { return "string" }
        if value is [Any] { return "array" }
        if value is [String: Any] { return "object" }
        return "unknown"
    }
}
