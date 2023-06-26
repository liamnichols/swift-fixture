#if compiler(>=5.9)
/// A macro used to automatically synthesize ``FixtureProviding`` conformance for a given type.
///
/// Attach `@FixtureProviding` to the member that you wish to vend a fixture for:
///
/// ```swift
/// import SwiftFixture
///
/// @FixtureProviding
/// struct User {
///     var id: UUID
///     var name: String
///     var createdAt: Date
///     var isActive: Bool
/// }
/// ```
@attached(member, names: named(provideFixture))
@attached(conformance)
public macro ProvideFixture() = #externalMacro(
    module: "SwiftFixtureMacros",
    type: "ProvideFixtureMacro"
)
#endif
