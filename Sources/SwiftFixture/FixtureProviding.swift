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

// MARK: - Conformances

/// `fixture()` support for `Array` types
extension Array: FixtureProviding {
    /// Provide a fixture value for use in testing of a given `Array` type.
    ///
    /// - Throws: Any error thrown when resolving a fixture for `Element` apart from ``ResolutionError``.
    /// - Returns: If a fixture can be provided for the `Element` type, an array with a single item will be returned.
    ///   If `Element` cannot be represented as a fixture because it was not registered, an empty array will be returned instead.
    public static func provideFixture(using values: ValueProvider) throws -> Array<Element> {
        do {
            return [try values.get()]
        } catch is ResolutionError {
            return Array()
        } catch {
            throw error
        }
    }
}

/// `fixture()` support for `Set` types
extension Set: FixtureProviding {
    /// Provide a fixture value for use in testing of a given `Set` type.
    ///
    /// - Throws: Any error thrown when resolving a fixture for `Element` apart from ``ResolutionError``.
    /// - Returns: If a fixture can be provided for the `Element` type, a set with a single item will be returned.
    ///   If `Element` cannot be represented as a fixture because it was not registered, an empty set will be returned instead.
    public static func provideFixture(using values: ValueProvider) throws -> Set<Element> {
        do {
            return [try values.get()]
        } catch is ResolutionError {
            return Set()
        } catch {
            throw error
        }
    }
}

/// `fixture()` support for `Dictionary` types
extension Dictionary: FixtureProviding {
    /// Provide a fixture value for use in testing of a given `Dictionary` type.
    ///
    /// - Throws: Any error thrown when resolving a fixture for `Key` or `Value` apart from ``ResolutionError``.
    /// - Returns: If a fixture can be provided for the `Key` and `Value` type, a dictionary with a single entry will be returned.
    ///   If `Key` or `Value` cannot be represented as a fixture because it was not registered, an empty dictionary will be returned instead.
    public static func provideFixture(using values: ValueProvider) throws -> Dictionary<Key, Value> {
        do {
            return [try values.get(): try values.get()]
        } catch is ResolutionError {
            return Dictionary()
        } catch {
            throw error
        }
    }
}
