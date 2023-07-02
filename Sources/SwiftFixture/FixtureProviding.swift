/// Describes a type that can provide fixture instances of itself for use in testing.
///
/// ```swift
/// import Foundation
/// import SwiftFixture
///
/// struct User: FixtureProviding {
///     let id: UUID
///     let name: String
///     let location: Location
///
///     static func provideFixture(using values: ValueProvider) throws -> User {
///         User(
///             id: try values.get("id"),
///             name: try values.get("name"),
///             location: try values.get("location")
///         )
///     }
/// }
/// ```
public protocol FixtureProviding {
    /// Provide a fixture value for use in testing.
    ///
    /// Use the provided ``ValueProvider`` instance to obtain values that can then be used when initializing the type.
    ///
    /// - Parameter values: The instance suitable for providing values for the given fixture.
    /// - Returns: An instance of `Self` initialized with values suitable for use in testing.
    static func provideFixture(using values: ValueProvider) throws -> Self
}

// MARK: - Containers
extension Array: FixtureProviding {
    public static func provideFixture(using values: ValueProvider) throws -> Array<Element> {
        if let value: Element = try? values.get() {
            return [value]
        } else {
            return Array()
        }
    }
}

extension Set: FixtureProviding {
    public static func provideFixture(using values: ValueProvider) throws -> Set<Element> {
        if let value: Element = try? values.get() {
            return [value]
        } else {
            return Set()
        }
    }
}

extension Dictionary: FixtureProviding {
    public static func provideFixture(using values: ValueProvider) throws -> Dictionary<Key, Value> {
        if let key: Key = try? values.get(), let value: Value = try? values.get() {
            return [key: value]
        } else {
            return Dictionary()
        }
    }
}
