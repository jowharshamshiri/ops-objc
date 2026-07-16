// The failure taxonomy — WHOSE problem a failure is
// (docs/failure-taxonomy.md, mirrors Rust ops::FailureClass).
//
// Declared at the error's DEFINITION site and carried structurally through
// every hop; no layer ever infers another layer's class from message text.
// An error that reaches a boundary without a declared class is `.internal`
// — unclassified means "ours", never a guess.

/// Whose problem a failure is. The raw value is the stable lowercase wire
/// token — used in the ERR frame meta, the machine_runs columns, the gRPC
/// proto, and the loom. One vocabulary everywhere.
public enum FailureClass: String, Sendable, CaseIterable, Equatable {
    /// Deterministic on the INPUT (context overflow, invalid request,
    /// unsupported format). The user's to fix; retrying can never succeed —
    /// tasks failing with this class are marked permanently failed.
    case input
    /// A compute resource was exhausted (GPU VRAM, host memory). Often
    /// transient (another process holding memory) — retryable.
    case resource
    /// The environment failed (network, registry, model download/integrity,
    /// cartridge process death). Transient by nature — retryable.
    case environment
    /// Everything else: a defect in the engine or a cartridge. Ours, said
    /// plainly. Retryable (races un-race), but never blamed on the user.
    case `internal`

    /// Whether retrying can NEVER succeed: the failure is a deterministic
    /// function of the input. Resource/environment/internal stay retryable
    /// (memory frees up, networks recover, races un-race).
    public var isPermanent: Bool {
        return self == .input
    }
}
