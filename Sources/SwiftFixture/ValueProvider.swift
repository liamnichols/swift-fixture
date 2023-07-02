import Foundation

/// Provides child fixture values within the ``Fixture/register(_:provideValue:)-7fin6`` and ``FixtureProviding/provideFixture(using:)`` methods.
public class ValueProvider {
    private let fixture: Fixture
    private let overrides: [String: Any]
    private let targetType: Any.Type
    private var consumedOverrides: Set<String> = []

    init(fixture: Fixture, overrides: [String: Any], targetType: Any.Type) {
        self.fixture = fixture
        self.overrides = overrides
        self.targetType = targetType
    }

    /// Gets a child value of a fixture either from the fixture argument overrides or by using the fixture resolution system.
    ///
    /// While `fixture()` gives the impression that it takes strongly typed arguments, it is actually a `@dynamicCallable` type and each argument is converted to a key-value pair at runtime. When calling this method, pass a string value for the `label` that matches the expected argument label in order to properly support overriding specific fixture values when creating instances.
    ///
    /// ```swift
    /// let user: User = try fixture(isActive: true)
    /// ```
    ///
    /// ```swift
    /// static func provideFixture(using values: ValueProvider) throws -> User {
    ///     User(
    ///         // ...
    ///         isActive: try values.get("isActive")
    ///     )
    /// }
    /// ```
    ///
    /// In the above example, `"isActive"` is specified to match the argument that is passed when calling `fixture()`.
    ///
    /// - Throws: ``ResolutionError/overrideTypeMismatch(_:_:_:)`` if the value passed into the `fixture()` cannot be represented by type `T`.
    /// - Throws: Errors produced by ``Fixture``'s value lookup in the event that an override is not used and a fixture value cannot be resolved.
    /// - Parameter label: The label of the argument to match this value to when performing a lookup.
    /// - Returns: A value of type `T` suitable for use as a test fixture.
    public func get<T>(_ label: String? = nil) throws -> T {
        // If an override was provided for the requested argument, try and use it
        if let label = label, let override = overrides[label] {
            if let value = override as? T {
                consumedOverrides.insert(label)
                return value
            } else {
                throw ResolutionError.overrideTypeMismatch(label, override, T.self)
            }
        }

        // Otherwise use the fixture value directly
        return try fixture.value(for: T.self, overrides: [:])
    }

    func ensureOverridesConsumed() throws {
        let unusedOverrides = Set(overrides.keys).subtracting(consumedOverrides)
        if let first = unusedOverrides.first {
            throw ResolutionError.unusedOverride(first, targetType)
        }
    }
}
