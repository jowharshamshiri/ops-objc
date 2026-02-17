import Foundation

// MARK: - DryContext helper functions (equivalent of Rust macros)

/// Store a value in DryContext using the given key.
public func dryPut<T: Encodable>(_ value: T, for key: String, in ctx: DryContext) {
    ctx.insert(value, for: key)
}

/// Retrieve an optional value from DryContext by key.
public func dryGet<T: Decodable>(_ type: T.Type = T.self, for key: String, from ctx: DryContext) -> T? {
    ctx.get(type, for: key)
}

/// Retrieve a required value from DryContext by key, throwing on missing or type mismatch.
public func dryRequire<T: Decodable>(_ type: T.Type = T.self, for key: String, from ctx: DryContext) throws -> T {
    try ctx.getRequired(type, for: key)
}

/// Store a result under both the op name key and the "result" key.
public func dryResult<T: Encodable>(_ result: T, opName: String, in ctx: DryContext) {
    ctx.insert(result, for: opName)
    ctx.insert(result, for: "result")
}

// MARK: - WetContext helper functions (equivalent of Rust macros)

/// Store a reference in WetContext using the given key.
public func wetPutRef<T>(_ value: T, for key: String, in ctx: WetContext) {
    ctx.insertRef(value, for: key)
}

/// Retrieve a required reference from WetContext, throwing on missing or type mismatch.
public func wetRequireRef<T>(_ type: T.Type = T.self, for key: String, from ctx: WetContext) throws -> T {
    try ctx.getRequired(type, for: key)
}

// MARK: - Control flow helpers

/// Abort the current operation, setting the abort flag and throwing an aborted error.
public func abort(dry: DryContext, reason: String? = nil) throws -> Never {
    dry.setAbort(reason: reason)
    throw OpError.aborted(reason ?? "Operation aborted")
}

/// Signal that the current loop iteration should be skipped (continue to next iteration).
/// The LoopOp catches OpError._loopContinue and handles it as continue control flow.
public func continueLoop(dry: DryContext) throws -> Never {
    if let loopId = dry.get(String.self, for: "__current_loop_id") {
        dry.insert(true, for: "__continue_loop_\(loopId)")
    }
    throw OpError._loopContinue
}

/// Signal that the loop should exit immediately (break out of the entire loop).
/// The LoopOp catches OpError._loopBreak and handles it as break control flow.
public func breakLoop(dry: DryContext) throws -> Never {
    if let loopId = dry.get(String.self, for: "__current_loop_id") {
        dry.insert(true, for: "__break_loop_\(loopId)")
    }
    throw OpError._loopBreak
}

/// Check if the abort flag is set, and throw if so.
public func checkAbort(dry: DryContext) throws {
    if dry.isAborted {
        let reason = dry.abortReason ?? "Operation aborted"
        throw OpError.aborted(reason)
    }
}
