import Foundation

///
public enum ResolutionError: Error {
    /// An error that is thrown when attempting to resolve a value for a type that is not registered
    case noProviderRegisteredForType(Any.Type)
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
        }
    }
}
