/// An object designed for vending fixture values for use in testing.
///
/// `Fixture` registerers providers for the most common system types. These providers by default will vend random values:
///
/// ```swift
/// let fixture = Fixture()
/// // ...
/// try fixture() as Int // Int.random(in: 0 ... .max)
/// ```
///
/// Alternatively, you can create an instance that vends constant values each time:
///
/// ```swift
/// let fixture = Fixture(preferredFormat: .constant)
/// // ...
/// try fixture() as Int // 0
/// ```
///
/// `Fixture` is a [Callable type](https://github.com/apple/swift-evolution/blob/main/proposals/0253-callable.md) so values are retrieved using function call syntax.
///
/// For your own container types, use the ``register(_:provideValue:)-7fin6`` method to configure a provider for that given type:
///
/// ```swift
/// struct User {
///     var id: UUID
///     var name: String
///     var updatedAt: Date?
///     var isActive: Bool
///     var favoriteNumbers: [Int]
/// }
///
/// let fixture = Fixture()
/// fixture.register(User.self) { fixture in
///     User(
///         id: try fixture(),
///         name: try fixture(),
///         updatedAt: try fixture(),
///         isActive: try fixture(),
///         favoriteNumbers: try fixture(count: 3)
///     )
/// }
///
/// try fixture() as User
/// // ▿ User
/// //   ▿ id: 27310087-1F15-4033-B97B-9E6873B48918
/// //     - uuid: "27310087-1F15-4033-B97B-9E6873B48918"
/// //   - name: "c8d24627-15fa-4b25-893b-141701bde934"
/// //   ▿ updatedAt: Optional(2012-05-24 21:13:02 +0000)
/// //     ▿ some: 2012-05-24 21:13:02 +0000
/// //       - timeIntervalSinceReferenceDate: 359586782.8698358
/// //   - isActive: false
/// //   ▿ favoriteNumbers: 3 elements
/// //     - 2045971833655816122
/// //     - 4965076267247534876
/// //     - 5467430163130934062
/// ```
@dynamicCallable
open class Fixture {
    private typealias AnyProvider = (ValueProvider) throws -> Any

    /// A lookup of closures used to provide fixture values keyed by the type name
    private var providers: [String: AnyProvider] = [:]

    /// Creates a fixture instance with builtin fixture types using the preferred format provided.
    ///
    /// - Parameter preferredFormat: The preferred format used when vending fixture values. Defaults to ``PreferredFormat/random``.
    public init(preferredFormat: PreferredFormat = .random) {
        registerDefaults(using: preferredFormat)
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
    /// fixture.register(MyType.self) { fixture in
    ///     MyType(title: try fixture(), count: try fixture())
    /// }
    /// ```
    ///
    /// The `provideValue` closure is passed the instance of ``Fixture`` in order to allow you to resolve fixture values for properties of container types.
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
    /// fixture.register(Int.self) { "42" }
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

    public func dynamicallyCall<T>(withKeywordArguments overrides: [String: Any]) throws -> T {
        try value(for: T.self, overrides: overrides)
    }
}
