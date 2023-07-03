import Foundation

enum ExpansionError: Error {
    case noInitializers
    case tooManyInitializers
}

extension ExpansionError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .noInitializers:
            return """
            @ProvideFixture requires that at least one initializer is defined
            """
        case .tooManyInitializers:
            return """
            @ProvideFixture is unable to disambiguate between multiple initializers
            """
        }
    }
}
