#if compiler(>=5.9)
/// A macro used to automatically synthesize ``FixtureProviding`` conformance for a given type.
///
/// Attach `@FixtureProviding` to the member that you wish to vend a fixture for:
///
/// ```swift
/// import SwiftFixture
///
/// @ProvideFixture
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
///             return #initFixture(with: values, using: User.init(id:name:createdAt:isActive:))
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
public macro initFixture<T>(with valueProvider: ValueProvider, using unappliedMethodReference: Any) -> T = #externalMacro(
    module: "SwiftFixtureMacros",
    type: "InitFixtureMacro"
)

/// A macro used for registering custom container types within a ``Fixture`` instance.
///
/// Provide the macro with a type, a reference to ``Fixture`` and the unapplied method reference that should be used to instantiate the fixture and am expression that calls ``Fixture/register(_:provideValue:)-7fin6`` will be expanded.
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
///         #register(User.self, in: fixture, using: User.init(id:name:createdAt:isActive:))
///     }
/// }
/// ```
///
/// This macro is similar to the ``initFixture(with:using:)`` macro, but adds an additional layer of convenience by expanding the ``Fixture/register(_:provideValue:)-7fin6`` call as well.
///
/// - SeeAlso: ``fixture(_:)``
@freestanding(expression)
public macro register<T>(
    _ type: T.Type,
    in fixture: Fixture,
    using unappliedMemberReference: Any
) = #externalMacro(
    module: "SwiftFixtureMacros",
    type: "RegisterMacro"
)

/// A macro used for creating an instance of ``Fixture`` that registers a series of custom container types.
///
/// Use this macro instead of ``register(_:in:using:)`` or ``initFixture(with:using:)`` to group the registration of multiple types using a single macro.
///
/// ```swift
/// struct User {
///     var id: UUID
///     var name: String
///     var createdAt: Date
///     var isActive: Bool
/// }
///
/// struct Group {
///     var id: UUID
///     var owner: User
///     var members: [User]
/// }
///
/// // ...
///
/// class UserTests: XCTestCase {
///     let fixture = #fixture(
///         User.init(id:name:createdAt:isActive:),
///         Group.init(id:owner:members:)
///     )
///
///     // ...
/// }
/// ```
@freestanding(expression)
public macro fixture(_ registering: Any...) -> Fixture = #externalMacro(
    module: "SwiftFixtureMacros",
    type: "FixtureMacro"
)
#endif
