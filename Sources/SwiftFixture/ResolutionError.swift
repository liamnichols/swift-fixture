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
            A value could not be resolved for the type ‘\(type)‘. \
            You can register it using the ‘register(_:provideValue:)‘ method, \
            or file an issue if you believe that it should have been resolved automatically.
            """
        case .overrideTypeMismatch(let label, let value, let expectedType):
            return """
            An override was provided for the argument ‘\(label)‘  but the value \
            (\(value)) does not match the required type ‘\(expectedType)‘.
            """
        case .unusedOverride(let label, let type):
            return """
            An override was provided for the argument ‘\(label)‘ \
            but was unused by the fixture ‘\(type)‘.
            """
        }
    }
}
