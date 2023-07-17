import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct InitFixtureMacro: ExpressionMacro {
    public static func expansion<Node: FreestandingMacroExpansionSyntax, Context: MacroExpansionContext>(
        of node: Node,
        in context: Context
    ) throws -> ExprSyntax {
        guard node.argumentList.count == 2 else {
            fatalError("compiler bug: the macro should have two arguments")
        }

        // Read information from each argument
        let valueProvider = node.argumentList.first!.expression
        let (type, name, arguments) = try initializerReference(from: node.argumentList.last!)

        // Resolve the callee expression based on the method reference to be used
        let identifier = IdentifierExprSyntax(identifier: type)
        let callee: ExprSyntaxProtocol
        if let name {
            callee = MemberAccessExprSyntax(base: identifier, name: name)
        } else {
            callee = identifier
        }

        // Return a function call to the method/initialiser
        return ExprSyntax(FunctionCallExprSyntax(callee: callee, rightParen: .rightParenToken(leadingTrivia: .newline)) {
            for label in arguments {
                TupleExprElementSyntax(
                    leadingTrivia: .newline,
                    label: label.flatMap({ TokenSyntax(.identifier($0), presence: .present) }),
                    colon: label == nil ? .none : .colonToken(),
                    expression: TryExprSyntax(
                        expression: FunctionCallExprSyntax(
                            calledExpression: MemberAccessExprSyntax(base: valueProvider, name: "get"),
                            leftParen: .leftParenToken(),
                            rightParen: .rightParenToken()
                        ) {
                            if let label {
                                TupleExprElementSyntax(expression: StringLiteralExprSyntax(content: label))
                            }
                        }
                    )
                )
            }
        })
    }

    private static func initializerReference(
        from argument: TupleExprElementListSyntax.Element
    ) throws -> (type: TokenSyntax, name: TokenSyntax?, arguments: [String?]) {
        guard argument.label?.text == "using" else {
            fatalError("compiler bug: third macro argument must be the intiailizer function signature")
        }

        guard let expression = argument.expression.as(MemberAccessExprSyntax.self) else {
            // TODO: We could offer a fixit suggestion here if the type was defined as a generic argument
            throw DiagnosticsError(diagnostics: [
                DiagnosticMessages.requiresUnappliedMethodReference.diagnose(at: argument.expression)
            ])
        }

        guard let base = expression.base?.as(IdentifierExprSyntax.self) else {
            throw DiagnosticsError(diagnostics: [
                DiagnosticMessages.requiresBaseTypeOfUnappliedMethodReference.diagnose(at: expression.dot)
            ])
        }

        let name: TokenSyntax?
        switch expression.name.tokenKind {
        case .identifier:
            name = expression.name
        case .keyword(.`init`):
            name = nil
        default:
            fatalError("compiler bug: unexpected expression name token")
        }

        guard let declNameArguments = expression.declNameArguments else {
            throw DiagnosticsError(diagnostics: [
                DiagnosticMessages.requiresUnappliedMethodReferenceDeclarationNameArgumentList.diagnose(
                    at: expression,
                    position: expression.endPosition
                )
            ])
        }

        return (
            type: base.identifier,
            name: name,
            arguments: declNameArguments.arguments.map { argument in
                switch argument.name.tokenKind {
                case .wildcard:
                    return nil
                case .identifier(let label):
                    return label
                default:
                    fatalError("unexpected token kind in decl arguments list")
                }
            }
        )
    }
}
