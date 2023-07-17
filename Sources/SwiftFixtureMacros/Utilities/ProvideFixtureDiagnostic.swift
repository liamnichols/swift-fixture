import SwiftSyntax
import SwiftDiagnostics

struct ProvideFixtureDiagnostic: DiagnosticMessage {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity

    static var unsupportedMember: Self {
        ProvideFixtureDiagnostic(
            message: "@ProvideFixture cannot be attached to this member",
            diagnosticID: .init(domain: "ProvideFixtureDiagnostic", id: "unsupportedMember"),
            severity: .error
        )
    }

    static var noInitializers: Self {
        ProvideFixtureDiagnostic(
            message: "@ProvideFixture requires that at least one initializer is defined",
            diagnosticID: .init(domain: "ProvideFixtureDiagnostic", id: "noInitializers"),
            severity: .error
        )
    }

    static var tooManyInitializers: Self {
        ProvideFixtureDiagnostic(
            message: "@ProvideFixture is unable to disambiguate between multiple initializers",
            diagnosticID: .init(domain: "ProvideFixtureDiagnostic", id: "tooManyInitializers"),
            severity: .error
        )
    }
}
