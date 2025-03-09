import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftDiagnostics
import SwiftSyntaxMacros

public struct FixtureMacro: ExpressionMacro {
    public static func expansion<Node: FreestandingMacroExpansionSyntax, Context: MacroExpansionContext>(
        of node: Node,
        in context: Context
    ) throws -> ExprSyntax {
        // Parse the unapplied method references
        let registrations = try node.argumentList.map {
            try $0.expression.unappliedMethodReference
        }

        // Produce the expanded code
        // Fixture()
        let fixtureInit = InitializerClauseSyntax(value: FunctionCallExprSyntax(
            callee: DeclReferenceExprSyntax(baseName: "Fixture"),
            leftParen: .leftParenToken(),
            rightParen: .rightParenToken()
        ))

        // fixture
        let fixtureVar = DeclReferenceExprSyntax(baseName: "fixture")

        // {
        //     let fixture = Fixture()
        //     #register(MyType.self, in: fixture, using: MyType.init(foo:bar:)
        //     return fixture
        // }()
        return ExprSyntax(FunctionCallExprSyntax(
            calledExpression: try ClosureExprSyntax {
                // let fixture = Fixture()
                VariableDeclSyntax(
                    .`let`,
                    name: .init(stringLiteral: fixtureVar.baseName.text),
                    initializer: fixtureInit
                )
                
                // #register(MyType.self, in: fixture, using: MyType.init(foo:bar:)
                for unappliedMethodReference in registrations {
                    try RegisterMacro.expansion(
                        type: MemberAccessExprSyntax(base: unappliedMethodReference.base, name: "self"),
                        fixture: fixtureVar,
                        unappliedMethodReference: unappliedMethodReference
                    )
                }
                
                // return fixture
                ReturnStmtSyntax(expression: fixtureVar)
            },
            leftParen: .leftParenToken(),
            arguments: [],
            rightParen: .rightParenToken()
        ))
    }
}
