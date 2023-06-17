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
///     static func provideFixture(using fixture: Fixture) throws -> User {
///         User(
///             id: try fixture(),
///             name: try fixture(),
///             location: try fixture()
///         )
///     }
/// }
/// ```
public protocol FixtureProviding {
    /// Provide a fixture value for use in testing.
    ///
    /// Use the provided ``Fixture`` instance to provide values that are used when initialising your own type.
    ///
    /// - Parameter fixture: The instance of ``Fixture`` used for resolving this and other fixture values.
    /// - Returns: An instance of `Self` initialized with values suitable for use in testing.
    static func provideFixture(using fixture: Fixture) throws -> Self
}
