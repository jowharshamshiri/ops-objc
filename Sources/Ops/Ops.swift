import Foundation

// MARK: - Central execution utilities

/// Central execution function with automatic logging wrapper.
public func perform<T: Sendable>(
    _ op: some Op<T>,
    dry: DryContext,
    wet: WetContext
) async throws -> T {
    let callerName = callerTriggerName()
    let wrapped = LoggingWrapper(op: AnyOp(op), name: callerName)
    return try await wrapped.perform(dry: dry, wet: wet)
}

/// Returns a string representing the caller context.
public func callerTriggerName(
    file: String = #file,
    line: Int = #line
) -> String {
    let filename = (file as NSString).lastPathComponent
        .replacingOccurrences(of: ".swift", with: "")
    return "\(filename)::\(line)"
}

// MARK: - Exception wrapping

/// Wrap a nested op exception with op name context.
public func wrapNestedOpException(_ triggerName: String, error: OpError) -> OpError {
    switch error {
    case .executionFailed(let msg):
        return .executionFailed("Op '\(triggerName)' failed: \(msg)")
    case .timeout(let ms):
        return .executionFailed("Op '\(triggerName)' timed out after \(ms)ms")
    case .context(let msg):
        return .context("Op '\(triggerName)' context error: \(msg)")
    case .batchFailed(let msg):
        return .batchFailed("Batch op '\(triggerName)' failed: \(msg)")
    // Classified failures keep their identity through wrapping — the wrap
    // adds human context to the CHAIN, never touches class/code/reason
    // (docs/failure-taxonomy.md).
    case .wrappedClassified(let chain, let code, let failureClass, let reason, let argUrn):
        return .wrappedClassified(
            chain: "Batch op '\(triggerName)' failed: \(chain)",
            code: code, failureClass: failureClass, reason: reason, argUrn: argUrn
        )
    case .classified(let code, let failureClass, let message, let argUrn):
        return .wrappedClassified(
            chain: "Op '\(triggerName)' failed: \(code): \(message)",
            code: code, failureClass: failureClass, reason: message, argUrn: argUrn
        )
    case .aborted(let reason):
        return .aborted("Op '\(triggerName)' aborted: \(reason)")
    case .trigger(let msg):
        return .trigger("Op '\(triggerName)' internal error: \(msg)")
    case .other(let err):
        return .executionFailed("Op '\(triggerName)' failed: \(err.localizedDescription)")
    case ._loopContinue, ._loopBreak:
        return error
    }
}

/// Wrap a runtime error into OpError.
public func wrapRuntimeException(_ error: any Error) -> OpError {
    return .executionFailed("Runtime error: \(describeError(error))")
}
