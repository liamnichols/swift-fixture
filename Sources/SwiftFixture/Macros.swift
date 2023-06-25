#if compiler(>=5.9)
/// A macro used to automatically synthesise ``FixtureProviding`` conformance for a given type.
@attached(member, names: named(provideFixture))
@attached(conformance)
public macro ProvideFixture() = #externalMacro(
    module: "SwiftFixtureMacros",
    type: "ProvideFixtureMacro"
)
#endif
