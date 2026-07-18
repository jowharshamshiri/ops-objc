import Foundation

/// Error type for op execution failures.
public enum OpError: Error, CustomStringConvertible, Sendable {
    case executionFailed(String)
    case timeout(timeoutMs: UInt64)
    case context(String)
    case batchFailed(String)
    /// A CLASSIFIED failure inside wrapping context (a batch child, a
    /// trigger-wrapped op, …) — the wrapper preserves the origin's failure
    /// identity instead of flattening it into prose. `chain` is the wrapping
    /// text (which op, which index) for humans; code/class/reason are the
    /// origin's, verbatim. (matches Rust OpError::WrappedClassified)
    case wrappedClassified(chain: String, code: String, failureClass: FailureClass, reason: String, argUrn: String?)
    case aborted(String)
    case trigger(String)
    /// A failure carrying its FULL identity from the emit source: the
    /// machine-readable code the origin error declares, the failure class it
    /// declares (whose problem it is), and the leaf human message. Wrapping
    /// layers construct `.wrappedClassified` from classified origins instead
    /// of folding everything into prose; the engine's run record and retry
    /// policy read it structurally. (matches Rust OpError::Classified)
    case classified(code: String, failureClass: FailureClass, message: String, argUrn: String?)
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
        case .wrappedClassified(let chain, _, _, _, _):
            return chain
        case .classified(let code, _, let message, _):
            return "\(code): \(message)"
        case .other(let err):
            return describeError(err)
        case ._loopContinue:
            return "Loop continue"
        case ._loopBreak:
            return "Loop break"
        }
    }

    /// The failure class this error DECLARES. Classified variants carry
    /// their origin's declaration; everything else is `.internal` —
    /// unclassified means "ours", never a guess (docs/failure-taxonomy.md).
    /// (matches Rust OpError::failure_class)
    public var failureClass: FailureClass {
        switch self {
        case .classified(_, let failureClass, _, _):
            return failureClass
        case .wrappedClassified(_, _, let failureClass, _, _):
            return failureClass
        default:
            return .internal
        }
    }

    /// The machine-readable code declared at the emit source, when the
    /// failure carried one. (matches Rust OpError::failure_code)
    public var failureCode: String? {
        switch self {
        case .classified(let code, _, _, _):
            return code
        case .wrappedClassified(_, let code, _, _, _):
            return code
        default:
            return nil
        }
    }

    /// Media URN of the argument attributed by the emit source, when any.
    /// Wrapping layers preserve this verbatim and never infer one.
    public var failureArgUrn: String? {
        switch self {
        case .classified(_, _, _, let argUrn),
             .wrappedClassified(_, _, _, _, let argUrn):
            return argUrn
        default:
            return nil
        }
    }

    /// The LEAF human reason — the origin's own message for classified
    /// failures, the description otherwise.
    /// (matches Rust OpError::failure_reason)
    public var failureReason: String {
        switch self {
        case .classified(_, _, let message, _):
            return message
        case .wrappedClassified(_, _, _, let reason, _):
            return reason
        default:
            return description
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
        case (.classified(let ac, let al, let am, let aa), .classified(let bc, let bl, let bm, let ba)):
            return ac == bc && al == bl && am == bm && aa == ba
        case (.wrappedClassified(let ah, let ac, let al, let ar, let aa), .wrappedClassified(let bh, let bc, let bl, let br, let ba)):
            return ah == bh && ac == bc && al == bl && ar == br && aa == ba
        case (._loopContinue, ._loopContinue): return true
        case (._loopBreak, ._loopBreak): return true
        default: return false
        }
    }
}
