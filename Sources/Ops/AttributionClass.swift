// Diagnostic attribution — whose domain a source record concerns.
// (docs/failure-taxonomy.md, mirrors Rust ops::AttributionClass).
//
// Declared at the error's DEFINITION site and carried structurally through
// every hop; no layer ever infers another layer's class from message text.
// An error that reaches a boundary without a declared class is `.internal`
// — unclassified means "ours", never a guess.

/// Attribution domain for ERR and non-progress LOG records. The raw value is
/// the stable lowercase wire token used by bifaci frame metadata and durable
/// run-failure fields. One vocabulary everywhere.
public enum AttributionClass: String, Sendable, CaseIterable, Equatable {
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
