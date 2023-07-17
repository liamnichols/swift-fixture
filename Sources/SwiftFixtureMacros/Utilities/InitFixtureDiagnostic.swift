import SwiftSyntax
import SwiftDiagnostics

struct InitFixtureDiagnostic: DiagnosticMessage {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity

    static var requiresUnappliedMethodReference: Self {
        InitFixtureDiagnostic(
            message: "Argument must be an unapplied method reference for a static method or initializer",
            diagnosticID: .init(domain: "InitFixtureDiagnostic", id: "requiresUnappliedMethodReference"),
            severity: .error
        )
    }

    static var requiresBaseTypeOfUnappliedMethodReference: Self {
        InitFixtureDiagnostic(
            message: "Unapplied method reference must explicitly define the base type",
            diagnosticID: .init(domain: "InitFixtureDiagnostic", id: "requiresBaseTypeOfUnappliedMethodReference"),
            severity: .error
        )
    }

    static var requiresUnappliedMethodReferenceDeclarationNameArgumentList: Self {
        InitFixtureDiagnostic(
            message: "Declaration name argument list must be provided",
            diagnosticID: .init(domain: "InitFixtureDiagnostic", id: "requiresUnappliedMethodReferenceDeclarationNameArgumentList"),
            severity: .error
        )
    }
}
