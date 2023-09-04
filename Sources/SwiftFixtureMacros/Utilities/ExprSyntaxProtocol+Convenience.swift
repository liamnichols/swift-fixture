import SwiftDiagnostics
import SwiftSyntax

typealias UnappliedMethodReference = (
    base: DeclReferenceExprSyntax,
    name: TokenSyntax?,
    arguments: DeclNameArgumentsSyntax,
    expression: MemberAccessExprSyntax
)

extension ExprSyntaxProtocol {
    func wrapInTry(_ wrapInTry: Bool = true) -> ExprSyntaxProtocol {
        if wrapInTry {
            return TryExprSyntax(expression: self)
        } else {
            return self
        }
    }

    var unappliedMethodReference: UnappliedMethodReference {
        get throws {
            // The receiver must be a member-access-expression
            guard let expression = self.as(MemberAccessExprSyntax.self) else {
                throw DiagnosticsError(diagnostics: [
                    DiagnosticMessages.requiresUnappliedMethodReference.diagnose(at: self)
                ])
            }

            // The base must be defined (i.e `User.init` vs just `.init`)
            guard let base = expression.base?.as(DeclReferenceExprSyntax.self) else {
                throw DiagnosticsError(diagnostics: [
                    DiagnosticMessages.requiresBaseTypeOfUnappliedMethodReference.diagnose(at: expression.period)
                ])
            }

            // It's possible that the reference isn't to an init statement, extract the method name if so
            // i.e `UserFactory.newUser(named:)` -> `newUser`
            let name: TokenSyntax? = switch expression.declName.baseName.tokenKind {
            case .identifier: expression.declName.baseName
            case .keyword(.`init`): nil
            default:
                fatalError("compiler bug: unexpected expression name token")
            }

            // The arguments must have been provided
            // It must be `User.init(name:)`, not `User.init`
            guard let declNameArguments = expression.declName.argumentNames else {
                throw DiagnosticsError(diagnostics: [
                    DiagnosticMessages.requiresUnappliedMethodReferenceDeclarationNameArgumentList.diagnose(
                        at: expression,
                        position: expression.endPosition,
                        fixIts: [] // TODO: Include a fixIt to add ()
                    )
                ])
            }

            // Return the extracted parameters
            return (base.trimmed, name?.trimmed, declNameArguments.trimmed, expression.trimmed)
        }
    }
}
