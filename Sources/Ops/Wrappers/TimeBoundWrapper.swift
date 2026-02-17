import Foundation

/// Wraps an op with a timeout, returning OpError.timeout if the op exceeds the duration.
public final class TimeBoundWrapper<T: Sendable>: Sendable {
    private let wrappedOp: AnyOp<T>
    private let timeoutDuration: TimeInterval
    private let triggerName: String?
    private let warnOnTimeout: Bool

    public init(op: AnyOp<T>, timeout: TimeInterval, name: String? = nil, warnOnTimeout: Bool = true) {
        self.wrappedOp = op
        self.timeoutDuration = timeout
        self.triggerName = name
        self.warnOnTimeout = warnOnTimeout
    }

    private var effectiveName: String {
        triggerName ?? "TimeBoundOp"
    }

    private func logTimeout() {
        if warnOnTimeout {
            print("Op '\(effectiveName)' was terminated due to timeout after \(timeoutDuration)s")
        }
    }

    private func logNearTimeout(duration: TimeInterval) {
        let ratio = duration / timeoutDuration
        if ratio > 0.8 {
            print("Op '\(effectiveName)' completed in \(String(format: "%.3f", duration))s (\(Int(ratio * 100))% of timeout)")
        }
    }

    public func perform(dry: DryContext, wet: WetContext) async throws -> T {
        let start = Date()
        let timeoutNs = UInt64(timeoutDuration * 1_000_000_000)

        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await self.wrappedOp.perform(dry: dry, wet: wet)
            }
            group.addTask {
                try await Task.sleep(nanoseconds: timeoutNs)
                throw OpError.timeout(timeoutMs: UInt64(self.timeoutDuration * 1000))
            }

            defer { group.cancelAll() }

            let result = try await group.next()!
            let duration = Date().timeIntervalSince(start)
            self.logNearTimeout(duration: duration)
            return result
        }
    }

    public func metadata() -> OpMetadata {
        let base = wrappedOp.metadata()
        if let name = triggerName {
            return OpMetadata(
                name: base.name,
                inputSchema: base.inputSchema,
                referenceSchema: base.referenceSchema,
                outputSchema: base.outputSchema,
                description: "\(name) (timeout: \(timeoutDuration)s)"
            )
        }
        return base
    }
}

// MARK: - Composite helper

public func createLoggedTimeoutWrapper<T: Sendable>(
    _ op: AnyOp<T>,
    timeout: TimeInterval,
    triggerName: String
) -> LoggingWrapper<T> {
    let timeoutWrapper = TimeBoundWrapper(op: op, timeout: timeout, name: triggerName)
    let timeoutAnyOp = AnyOp(TimeBoundOpAdapter(timeoutWrapper))
    return LoggingWrapper(op: timeoutAnyOp, name: "TimeBound[\(triggerName)]")
}

/// Adapter to make TimeBoundWrapper conform to Op protocol.
struct TimeBoundOpAdapter<T: Sendable>: Op, Sendable {
    typealias Output = T
    private let wrapper: TimeBoundWrapper<T>

    init(_ wrapper: TimeBoundWrapper<T>) {
        self.wrapper = wrapper
    }

    func perform(dry: DryContext, wet: WetContext) async throws -> T {
        try await wrapper.perform(dry: dry, wet: wet)
    }

    func metadata() -> OpMetadata {
        wrapper.metadata()
    }
}

// MARK: - Caller-name helper

public func createTimeoutWrapperWithCallerName<T: Sendable>(
    _ op: AnyOp<T>,
    timeout: TimeInterval,
    file: String = #file,
    line: Int = #line
) -> TimeBoundWrapper<T> {
    let name = callerTriggerName(file: file, line: line)
    return TimeBoundWrapper(op: op, timeout: timeout, name: name)
}
