/// The preferred format of fixture values provided by ``Fixture``.
///
/// - Note: This value is only guaranteed to influence the default registered types and may be ignored elsewhere.
public enum PreferredFormat {
    /// Prefer random fixture values.
    case random

    /// Prefer constant fixture values for a given type.
    case constant
}
