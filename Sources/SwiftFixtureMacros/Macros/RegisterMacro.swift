import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftDiagnostics
import SwiftSyntaxMacros

public struct RegisterMacro: ExpressionMacro {
    public static func expansion<Node: FreestandingMacroExpansionSyntax, Context: MacroExpansionContext>(
        of node: Node,
        in context: Context
    ) throws -> ExprSyntax {
        guard node.argumentList.count == 3 else {
            fatalError("compiler bug: the macro must contain three arguments")
        }
        
        let args = Array(node.argumentList)
        let typeExpr = args[0].expression.trimmed
        let fixtureExpr = args[1].expression.trimmed
        let methodExpr = args[2].expression.trimmed
        
        return ExprSyntax(try expansion(
            type: typeExpr,
            fixture: fixtureExpr,
            unappliedMethodReference: try methodExpr.unappliedMethodReference
        ))
    }

    internal static func expansion(
        type: some ExprSyntaxProtocol,
        fixture: some ExprSyntaxProtocol,
        unappliedMethodReference: UnappliedMethodReference
    ) throws -> FunctionCallExprSyntax {
        // { values in
        //     #initFixture(...)
        // }
        let valuesId = DeclReferenceExprSyntax(baseName: "values")
        let closure = try ClosureExprSyntax(simpleInput: [
            ClosureShorthandParameterSyntax(name: valuesId.baseName)
        ]) {
            try InitFixtureMacro.expansion(
                valueProvider: valuesId,
                unappliedMethodReference: unappliedMethodReference
            )
        }

        // fixture.register(MyType.self) { values in ... }
        return FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(base: fixture, name: "register"),
            leftParen: .leftParenToken(),
            arguments: [LabeledExprSyntax(expression: type)],
            rightParen: .rightParenToken(),
            trailingClosure: closure
        )
    }
}
