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

        return ExprSyntax(try expansion(
            valueProvider: node.argumentList.first!.trimmed.expression,
            unappliedMethodReference: try node.argumentList.last!.expression.unappliedMethodReference
        ))
    }

    internal static func expansion(
        valueProvider: some ExprSyntaxProtocol,
        unappliedMethodReference: UnappliedMethodReference
    ) throws -> FunctionCallExprSyntax {
        // Resolve the callee expression based on the method reference to be used
        let callee: ExprSyntaxProtocol = if let name = unappliedMethodReference.name {
            MemberAccessExprSyntax(base: unappliedMethodReference.base, name: name) // MyType.myMethod
        } else {
            unappliedMethodReference.base // MyType
        }

        // Return a function call to the method/initialiser
        // MyType(
        //     foo: try values.get("foo")
        //     bar: try values.get("bar")
        // )
        return FunctionCallExprSyntax(callee: callee, rightParen: .rightParenToken(leadingTrivia: .newline)) {
            for label in unappliedMethodReference.arguments.labels {
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
        }
    }
}
