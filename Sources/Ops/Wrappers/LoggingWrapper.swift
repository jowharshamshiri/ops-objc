import Foundation

// ANSI color codes matching Rust reference
private let YELLOW = "\u{1b}[33m"
private let GREEN = "\u{1b}[32m"
private let RED = "\u{1b}[31m"
private let RESET = "\u{1b}[0m"

/// Wraps an op with logging on start, success, and failure.
public final class LoggingWrapper<T: Sendable>: Sendable {
    private let wrappedOp: AnyOp<T>
    private let triggerName: String
    private let loggerName: String

    public init(op: AnyOp<T>, name: String, loggerName: String? = nil) {
        self.wrappedOp = op
        self.triggerName = name
        self.loggerName = loggerName ?? "LoggingWrapper"
    }

    private func logStart() {
        print("\(YELLOW)Starting op: \(triggerName)\(RESET)")
    }

    private func logSuccess(duration: TimeInterval) {
        print("\(GREEN)Op '\(triggerName)' completed in \(String(format: "%.3f", duration)) seconds\(RESET)")
    }

    private func logFailure(error: OpError, duration: TimeInterval) {
        print("\(RED)Op '\(triggerName)' failed after \(String(format: "%.3f", duration)) seconds: \(error.description)\(RESET)")
    }

    public func perform(dry: DryContext, wet: WetContext) async throws -> T {
        let start = Date()
        logStart()
        do {
            let result = try await wrappedOp.perform(dry: dry, wet: wet)
            logSuccess(duration: Date().timeIntervalSince(start))
            return result
        } catch let err as OpError {
            let duration = Date().timeIntervalSince(start)
            logFailure(error: err, duration: duration)
            throw wrapNestedOpException(triggerName, error: .executionFailed(err.description))
        } catch {
            let duration = Date().timeIntervalSince(start)
            let opErr = OpError.executionFailed(error.localizedDescription)
            logFailure(error: opErr, duration: duration)
            throw wrapNestedOpException(triggerName, error: opErr)
        }
    }

    public func metadata() -> OpMetadata {
        wrappedOp.metadata()
    }
}

// MARK: - Context-aware logger helper

public func createContextAwareLogger<T: Sendable>(
    _ op: AnyOp<T>,
    file: String = #file,
    line: Int = #line
) -> LoggingWrapper<T> {
    let name = callerTriggerName(file: file, line: line)
    return LoggingWrapper(op: op, name: name, loggerName: name)
}

// MARK: - Internal color constants access for tests

public enum ANSIColors {
    public static let yellow = YELLOW
    public static let green = GREEN
    public static let red = RED
    public static let reset = RESET
}
