import Foundation

/// Describes errors thrown by SwiftFixture when a requested fixture value cannot be resolved.
public enum ResolutionError: Error {
    /// An error that is thrown when attempting to resolve a value for a type that is not registered.
    case noProviderRegisteredForType(Any.Type)

    /// An override was provided but the type did not match the requirement of the fixture.
    case overrideTypeMismatch(String, Any, Any.Type)

    /// An override was specified at the call site but was not used by the fixture value provider.
    case unusedOverride(String, Any.Type)
}

extension ResolutionError: LocalizedError {
    public var errorDescription: String? {
        String(reflecting: self)
    }
}

extension ResolutionError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .noProviderRegisteredForType(let type):
            return """
            A value could not be resolved for the type \(type). \
            You can register it using the ‘register(_:provideValue:)‘ method, \
            or file an issue if you believe that it should have been resolved automatically.
            """
        case .overrideTypeMismatch(let label, let value, let expectedType):
            return """
            An override was provided as \(type(of: value)) for the argument ‘\(label)‘ but \
            \(expectedType) was expected.
            """
        case .unusedOverride(let label, let type):
            return """
            The argument ‘\(label)‘ was specified but is not used by the fixture for \(type).
            """
        }
    }
}
