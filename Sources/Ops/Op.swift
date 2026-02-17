import Foundation

/// The fundamental protocol for composable operations.
public protocol Op<Output>: Sendable {
    associatedtype Output: Sendable

    func perform(dry: DryContext, wet: WetContext) async throws -> Output
    func metadata() -> OpMetadata
    func rollback(dry: DryContext, wet: WetContext) async throws
}

/// Default no-op rollback implementation.
public extension Op {
    func rollback(dry: DryContext, wet: WetContext) async throws {
        // Default: no-op
    }
}

/// Type-erased wrapper for any Op<T>.
public final class AnyOp<T: Sendable>: Sendable {
    private let _perform: @Sendable (DryContext, WetContext) async throws -> T
    private let _metadata: @Sendable () -> OpMetadata
    private let _rollback: @Sendable (DryContext, WetContext) async throws -> Void

    public init<O: Op>(_ op: O) where O.Output == T {
        _perform = { [op] dry, wet in try await op.perform(dry: dry, wet: wet) }
        _metadata = { [op] in op.metadata() }
        _rollback = { [op] dry, wet in try await op.rollback(dry: dry, wet: wet) }
    }

    public func perform(dry: DryContext, wet: WetContext) async throws -> T {
        try await _perform(dry, wet)
    }

    public func metadata() -> OpMetadata {
        _metadata()
    }

    public func rollback(dry: DryContext, wet: WetContext) async throws {
        try await _rollback(dry, wet)
    }
}
