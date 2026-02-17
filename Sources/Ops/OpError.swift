import Foundation

/// Error type for op execution failures.
public enum OpError: Error, CustomStringConvertible, Sendable {
    case executionFailed(String)
    case timeout(timeoutMs: UInt64)
    case context(String)
    case batchFailed(String)
    case aborted(String)
    case trigger(String)
    case other(any Error & Sendable)

    /// Internal control-flow signals used by LoopOp. Never escape to callers.
    case _loopContinue
    case _loopBreak

    public var description: String {
        switch self {
        case .executionFailed(let msg):
            return "Op execution failed: \(msg)"
        case .timeout(let ms):
            return "Op timeout after \(ms)ms"
        case .context(let msg):
            return "Context error: \(msg)"
        case .batchFailed(let msg):
            return "Batch op failed: \(msg)"
        case .aborted(let msg):
            return "Op aborted: \(msg)"
        case .trigger(let msg):
            return "Trigger error: \(msg)"
        case .other(let err):
            return describeError(err)
        case ._loopContinue:
            return "Loop continue"
        case ._loopBreak:
            return "Loop break"
        }
    }
}

/// Extracts a human-readable description from an arbitrary Error.
/// Swift's `localizedDescription` on `any Error` existentials bypasses custom property implementations
/// and goes through Foundation's NSError bridge. Instead, prefer `LocalizedError.errorDescription` and
/// fall back to `String(describing:)` which includes stored property values for custom struct errors.
func describeError(_ error: any Error) -> String {
    if let le = error as? LocalizedError, let desc = le.errorDescription {
        return desc
    }
    return String(describing: error)
}

extension OpError: Equatable {
    public static func == (lhs: OpError, rhs: OpError) -> Bool {
        switch (lhs, rhs) {
        case (.executionFailed(let a), .executionFailed(let b)): return a == b
        case (.timeout(let a), .timeout(let b)): return a == b
        case (.context(let a), .context(let b)): return a == b
        case (.batchFailed(let a), .batchFailed(let b)): return a == b
        case (.aborted(let a), .aborted(let b)): return a == b
        case (.trigger(let a), .trigger(let b)): return a == b
        case (._loopContinue, ._loopContinue): return true
        case (._loopBreak, ._loopBreak): return true
        default: return false
        }
    }
}
