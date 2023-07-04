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

/// A macro used for initializing instances of a fixture type using a given ``ValueProvider`` object.
///
/// Provide the macro with a reference to the provided ``ValueProvider`` and the unapplied method reference to either the types initializer or a static method that returns an instance of the type
///
/// ```swift
/// struct User {
///     var id: UUID
///     var name: String
///     var createdAt: Date
///     var isActive: Bool
/// }
///
/// // ...
///
/// class UserTests: XCTestCase {
///     let fixture = Fixture()
///
///     override func setUp() {
///         super.setUp()
///
///         fixture.register(User.self) { values in
///             return #initFixture(using: values, with: User.init(id:name:createdAt:isActive:))
///         }
///     }
/// }
/// ```
///
/// ### Unapplied Method References
///
/// An unapplied method reference is syntax used to reference a method without actually calling (applying) it. The reference provided is essentially a closure type with the arguments of the method that can be called later on. For example:
///
/// ```swift
/// let method: (UUID, String, Date, Bool) -> User = User.init(id:name:createdAt:isActive:)
/// let user = method(UUID(), "", Date(), false) // Same as User(id: UUID(), name: "", createdAt: Date(), isActive: false)
/// ```
///
/// The `#initFixture` macro leverages this syntax because it contains the argument labels of the call that the macro generates while also having compile time guarantees that you are proving the macro with a reference.
@freestanding(expression)
public macro initFixture<T>(using valueProvider: ValueProvider, with unappliedMethodReference: Any) -> T = #externalMacro(
    module: "SwiftFixtureMacros",
    type: "InitFixtureMacro"
)
#endif
