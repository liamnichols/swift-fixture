/// An factory for vending fixture values for use in unit tests
///
/// Fixture is capable of vending non-deterministic values for common Swift types:
///
/// ```swift
/// let fixture = Fixture()
///
/// try fixture() as Int
/// // - 5363896279182060614
///
/// try fixture() as Date
/// // ▿ 2008-09-10 18:34:13 +0000
/// // - timeIntervalSinceReferenceDate: 242764453.45139748
///
/// try fixture() as String
/// // - "1b3e9b17-d79a-4056-8f2b-73112694fa5c"
/// ```
///
/// Additionally, custom types can be registered using the ``register(_:provideValue:)-7fin6`` method:
///
/// ```swift
/// struct User {
///     let id: UUID
///     let name: String
///     let createdAt: Date
///     let isActive: Bool
/// }
///
/// fixture.register(User.self) { values in
///     User(
///         id: try values.get("id"),
///         name: try values.get("name"),
///         createdAt: try values.get("createdAt"),
///         isActive: try values.get("isActive")
///     )
/// }
///
/// try fixture() as User
/// // ▿ User
/// //   ▿ id: 27310087-1F15-4033-B97B-9E6873B48918
/// //     - uuid: "27310087-1F15-4033-B97B-9E6873B48918"
/// //   - name: "1b3e9b17-d79a-4056-8f2b-73112694fa5c"
/// //   ▿ createdAt: 2012-05-24 21:13:02 +0000
/// //     - timeIntervalSinceReferenceDate: 359586782.8698358
/// //   - isActive: false
/// ```
///
/// For container type, arguments can be overridden dynamically:
///
/// ```swift
/// let user: User = try fixture(name: "John Appleseed", isActive: true)
/// user.name // "John Appleseed"
/// user.isActive // true
/// ```
///
/// See ``dynamicallyCall(withKeywordArguments:)`` for more information.
@dynamicCallable
open class Fixture {
    private typealias AnyProvider = (ValueProvider) throws -> Any

    /// A lookup of closures used to provide fixture values keyed by the type name
    private var providers: [String: AnyProvider] = [:]

    /// Creates a new instance for vending fixture values
    public init() {
        registerDefaultProviders()
    }
}

// MARK: - Registration
extension Fixture {
    /// Register a closure used to provide a value for the given type
    ///
    /// ``Fixture`` will retain the closure and invoke it when resolving values of the given type.
    /// If you register the same type multiple times, the last provider to be registered will be used.
    ///
    /// ```swift
    /// let fixture = Fixture()
    /// fixture.register(MyType.self) { values in
    ///     MyType(title: try values.get("title"), count: try values.get("count"))
    /// }
    /// ```
    ///
    /// The `provideValue` closure is passed the instance of ``FixtureProviding`` in order to allow you to resolve fixture values for properties of container types.
    ///
    /// - Parameters:
    ///   - type: The exact type being registered for future resolution
    ///   - provideValue: An escaping closure used to customise the fixture values of the given `type`.
    public func register<T>(_ type: T.Type, provideValue: @escaping (ValueProvider) throws -> T) {
        providers[String(reflecting: type)] = provideValue
    }

    /// Register a closure used to provide a value for the given type
    ///
    /// ``Fixture`` will retain the closure and invoke it when resolving values of the given type.
    /// If you register the same type multiple times, the last provider to be registered will be used.
    ///
    /// ```swift
    /// let fixture = Fixture()
    /// fixture.register(Int.self) { 42 }
    /// ```
    ///
    /// - Parameters:
    ///   - type: The exact type being registered for future resolution
    ///   - provideValue: An escaping closure used to customise the fixture values of the given `type`.
    public func register<T>(_ type: T.Type, provideValue: @escaping () throws -> T) {
        providers[String(reflecting: type)] = { _ in
            try provideValue()
        }
    }
}

// MARK: - Value Lookup
extension Fixture {
    private func value<T>(for type: Any.Type, using valueProvider: ValueProvider) throws -> T? {
        // Firstly try and retrieve the value from the registered providers since they take priority
        if let provideValue = providers[String(reflecting: type)] {
            return try provideValue(valueProvider) as? T
        }

        // Alternatively, the type might conform to FixtureProviding and if so, a value can be loaded via `provideFixture(using:)`
        if let type = type as? FixtureProviding.Type, let value = try type.provideFixture(using: valueProvider) as? T {
            return value
        }

        // Otherwise no value could be provided
        return nil
    }

    internal func value<T>(for type: T.Type, overrides: [String: Any]) throws -> T {
        // If T is an Optional type, expose the Wrapped type for value lookup
        let optionalType = type as? OptionalProtocol.Type
        let wrappedType = optionalType?.wrappedType ?? type

        // Create the ValueProvider class used for providing child values by incorporating overrides.
        let valueProvider = ValueProvider(fixture: self, overrides: overrides, targetType: wrappedType)

        // Resolve the value to the best of our ability and ensure that all overrides were consumed
        if let value = (try value(for: wrappedType, using: valueProvider) as T?) {
            try valueProvider.ensureOverridesConsumed()
            return value
        }

        // If a value could not be provided, either fallback to `nil` or throw a resolution error
        if let nilValue = optionalType?.nilValue as? T {
            return nilValue
        } else {
            throw ResolutionError.noProviderRegisteredForType(T.self)
        }
    }

    // MARK: Interface

    /// Resolves a fixture value of the given type.
    ///
    /// This method depends on type inference to resolve the correct fixture value so it is important to ensure that the call is correctly annotated.
    ///
    /// ```swift
    /// func doSomething(with anything: Any) { ... }
    ///
    /// let fixture = Fixture()
    /// doSomething(with: try fixture()) // ❌ Error: A value could not be resolved for the type Any.
    /// doSomething(with: try fixture() as Int) // ✅
    /// ```
    ///
    /// For container types, arguments can be overwritten when creating a fixture value:
    ///
    /// ```swift
    /// let user: User = try fixture(name: "John Appleseed", isActive: true)
    /// user.name // "John Appleseed"
    /// user.isActive // true
    /// ```
    ///
    /// Because overrides are read at runtime and not compile time, there are a couple of things to keep in mind:
    ///
    /// 1. The label of each argument must exactly match a value passed to the ``ValueProvider/get(_:)``. This typically should match the original property/argument name of the target type.
    /// 2. Specifying arguments that aren't used when resolving fixture values will result in ``ResolutionError/unusedOverride(_:_:)`` from being thrown. This is useful for identifying typos/property renames.
    /// 3. The value of each argument override must match the type of the original property otherwise the ``ResolutionError/overrideTypeMismatch(_:_:_:)`` error will be thrown.
    ///
    /// - Parameter overrides: Argument overrides to be used instead of standard fixture values. The labels of these arguments must match those used by the types fixture provider otherwise an error will be thrown.
    /// - Returns: A value suitable for use as a test fixture.
    public func dynamicallyCall<T>(withKeywordArguments overrides: [String: Any]) throws -> T {
        try value(for: T.self, overrides: overrides)
    }
}
