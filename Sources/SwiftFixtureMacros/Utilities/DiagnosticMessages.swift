import SwiftSyntax
import SwiftDiagnostics

struct DiagnosticMessages: DiagnosticMessage {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity

    private init(
        message: String,
        id: String,
        severity: DiagnosticSeverity = .error
    ) {
        self.message = message
        self.diagnosticID = .init(domain: "SwiftFixture", id: id)
        self.severity = severity
    }

    static var requiresUnappliedMethodReference: Self {
        Self(
            message: "Value must be an unapplied method reference for a static method or initializer",
            id: #function
        )
    }

    static var requiresBaseTypeOfUnappliedMethodReference: Self {
        Self(
            message: "Unapplied method reference must explicitly define the base type",
            id: #function
        )

    }

    static var requiresUnappliedMethodReferenceDeclarationNameArgumentList: Self {
        Self(
            message: "Unapplied method reference must explicitly define the argument list",
            id: #function
        )
    }

    static var unsupportedMember: Self {
        Self(
            message: "@ProvideFixture cannot be attached to this member",
            id: #function
        )
    }

    static var noInitializers: Self {
        Self(
            message: "@ProvideFixture requires that at least one initializer is defined",
            id: #function
        )
    }

    static var tooManyInitializers: Self {
        Self(
            message: "@ProvideFixture is unable to disambiguate between multiple initializers",
            id: #function
        )
    }
}
