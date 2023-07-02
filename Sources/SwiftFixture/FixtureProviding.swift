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
///             id: try values.value(labelled: "id"),
///             name: try values.value(labelled: "name"),
///             location: try values.value(labelled: "location")
///         )
///     }
/// }
/// ```
public protocol FixtureProviding {
    /// Provide a fixture value for use in testing.
    ///
    /// Use the provided ``ValueProvider`` instance to provide values that are used when initialising your own type.
    /// The value provider supports overrides passed at the call site when using the ``ValueProvider/value(labelled:)`` method.
    ///
    /// - Parameter values: The instance suitable for providing values for the given fixture.
    /// - Returns: An instance of `Self` initialized with values suitable for use in testing.
    static func provideFixture(using values: ValueProvider) throws -> Self
}
