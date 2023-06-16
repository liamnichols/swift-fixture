/// An object designed for vending fixture values for use in testing.
///
/// `Fixture` registerers providers for the most common system types. These providers by default will vend random values:
///
/// ```swift
/// let fixture = Fixture()
/// // ...
/// try fixture(Int.self) // Int.random(in: 0 ... .max)
/// ```
///
/// Alternatively, you can create an instance that vends constant values each time:
///
/// ```swift
/// let fixture = Fixture(preferredFormat: .constant)
/// // ...
/// try fixture(Int.self) // 0
/// ```
///
/// `Fixture` is a [Callable type](https://github.com/apple/swift-evolution/blob/main/proposals/0253-callable.md) so values are retrieved using function call syntax.
///
/// For your own container types, use the ``register(_:provideValue:)-i0ea`` method to configure a provider for that given type:
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
/// try fixture(User.self)
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
open class Fixture {
    private typealias AnyProvider = () throws -> Any

    /// A lookup of closures used to provide fixture values keyed by the type name
    private var providers: [String: AnyProvider] = [:]

    /// Creates a fixture instance with builtin fixture types using the preferred format provided.
    ///
    /// - Parameter preferredFormat: The preferred format used when vending fixture values. Defaults to ``PreferredFormat.random``.
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
    public func register<T>(_ type: T.Type, provideValue: @escaping (Fixture) throws -> T) {
        providers[String(reflecting: type)] = { [unowned self] in
            try provideValue(self)
        }
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
        providers[String(reflecting: type)] = {
            try provideValue()
        }
    }
}

// MARK: - Value Lookup
// TODO: Use something like Sorcery (eventually Macros) to simplify this overloading mess
// First define each base overload, then the Optional equivalent, then a callAsFunction version of both.
extension Fixture {
    /// Internal function for providing a fixture value via the registered provider for the given type
    private func providerValue<T>(for type: T.Type = T.self) throws -> T? {
        if let provideValue = providers[String(reflecting: type)] {
            return try provideValue() as? T
        } else {
            return nil
        }
    }

    // MARK: Base Overloads

    /// Resolves a fixture value for the given type or throws an error if it cannot be resolved.
    func value<T>(for type: T.Type = T.self) throws -> T {
        if let value = try providerValue(for: T.self) {
            return value
        }

        throw ResolutionError.noProviderRegisteredForType(T.self)
    }

    /// Resolves a fixture value for the given type or throws an error if it cannot be resolved.
    func value<T: RawRepresentable>(for type: T.Type = T.self) throws -> T {
        if let value = try providerValue(for: T.self) {
            return value
        }

        if let rawValue = try providerValue(for: T.RawValue.self), let value = T(rawValue: rawValue) {
            return value
        }

        throw ResolutionError.noProviderRegisteredForType(type)
    }

    /// Resolves a fixture value for the given type or throws an error if it cannot be resolved.
    func value<T: CaseIterable>(for type: T.Type = T.self) throws -> T {
        if let value = try providerValue(for: T.self) {
            return value
        }

        if let value = T.allCases.randomElement() {
            return value
        }

        throw ResolutionError.noProviderRegisteredForType(type)
    }

    /// Resolves a fixture value for the given type or throws an error if it cannot be resolved.
    func value<T>(for type: [T].Type = [T].self, count: Int = 1) throws -> [T] {
        try (0 ..< count).map { _ in try value(for: T.self) }
    }

    // TODO: Support other collection types (Set, Dictionary..)

    // MARK: Optional Overloads

    func value<T>(for type: Optional<T>.Type = Optional<T>.self) throws -> T? {
        do {
            return try value(for: T.self)
        } catch is ResolutionError {
            return nil
        } catch {
            throw error
        }
    }

    func value<T: RawRepresentable>(for type: Optional<T>.Type = Optional<T>.self) throws -> T? {
        do {
            return try value(for: T.self)
        } catch is ResolutionError {
            return nil
        } catch {
            throw error
        }
    }

    func value<T: CaseIterable>(for type: Optional<T>.Type = Optional<T>.self) throws -> T? {
        do {
            return try value(for: T.self)
        } catch is ResolutionError {
            return nil
        } catch {
            throw error
        }
    }

    func value<T>(for type: Optional<[T]>.Type = Optional<[T]>.self, count: Int = 1) throws -> [T]? {
        do {
            return try value(for: [T].self)
        } catch is ResolutionError {
            return nil
        } catch {
            throw error
        }
    }
}

// MARK: - Call As Function
public extension Fixture {
    func callAsFunction<T>(_ type: T.Type = T.self) throws -> T {
        try value(for: type)
    }

    func callAsFunction<T: RawRepresentable>(_ type: T.Type = T.self) throws -> T {
        try value(for: type)
    }

    func callAsFunction<T: CaseIterable>(_ type: T.Type = T.self) throws -> T {
        try value(for: type)
    }

    func callAsFunction<T>(_ type: Optional<T>.Type = Optional<T>.self) throws -> T? {
        try value(for: type)
    }

    func callAsFunction<T>(_ type: [T].Type = [T].self, count: Int = 1) throws -> [T] {
        try value(for: type, count: count)
    }

    func callAsFunction<T: RawRepresentable>(_ type: Optional<T>.Type = Optional<T>.self) throws -> T? {
        try value(for: type)
    }

    func callAsFunction<T: CaseIterable>(_ type: Optional<T>.Type = Optional<T>.self) throws -> T? {
        try value(for: type)
    }

    func callAsFunction<T>(_ type: Optional<[T]>.Type = Optional<[T]>.self, count: Int = 1) throws -> [T]? {
        try value(for: type, count: count)
    }
}
