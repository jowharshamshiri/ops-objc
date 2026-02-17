import Foundation

/// WetContext contains runtime references (services, connections, etc.).
/// Values are stored as type-erased Any and retrieved by type.
/// Thread-safe via a lock.
public final class WetContext: @unchecked Sendable {
    private let lock = NSLock()
    private var _references: [String: Any] = [:]

    public init() {}

    // MARK: - Builder

    public func withRef<T>(_ value: T, for key: String) -> WetContext {
        insertRef(value, for: key)
        return self
    }

    // MARK: - Insert

    public func insertRef<T>(_ value: T, for key: String) {
        lock.lock()
        defer { lock.unlock() }
        _references[key] = value
    }

    // MARK: - Get

    public func getRef<T>(_ type: T.Type = T.self, for key: String) -> T? {
        lock.lock()
        defer { lock.unlock() }
        return _references[key] as? T
    }

    public func getRequired<T>(_ type: T.Type = T.self, for key: String) throws -> T {
        lock.lock()
        let raw = _references[key]
        lock.unlock()
        guard let raw = raw else {
            throw OpError.context("Required wet context reference '\(key)' not found")
        }
        guard let typed = raw as? T else {
            throw OpError.context(
                "Type mismatch for wet context reference '\(key)': expected type '\(T.self)', but found a different type"
            )
        }
        return typed
    }

    public func contains(_ key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return _references[key] != nil
    }

    public var keys: [String] {
        lock.lock()
        defer { lock.unlock() }
        return Array(_references.keys)
    }

    // MARK: - Ensure

    public func ensure<T>(
        for key: String,
        dry: DryContext,
        factory: @Sendable (DryContext, WetContext, String) async throws -> T
    ) async throws -> T {
        if let existing = getRef(T.self, for: key) {
            return existing
        }
        let newValue = try await factory(dry, self, key)
        insertRef(newValue, for: key)
        return newValue
    }

    // MARK: - Merge

    public func merge(_ other: WetContext) {
        let otherRefs = other._references
        lock.lock()
        defer { lock.unlock() }
        for (k, v) in otherRefs {
            _references[k] = v
        }
    }
}
