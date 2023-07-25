import SwiftSyntax

extension MacroExpansionExprSyntax {
    static func initFixture(
        valueProvider: some ExprSyntaxProtocol,
        unappliedMethodReference: some ExprSyntaxProtocol
    ) -> Self {
        MacroExpansionExprSyntax(macro: "initFixture", leftParen: .leftParenToken(), rightParen: .rightParenToken()) {
            TupleExprElementSyntax(
                label: "with",
                expression: valueProvider
            )

            TupleExprElementSyntax(
                label: "using",
                expression: unappliedMethodReference
            )
        }
    }

    static func register(
        type: some ExprSyntaxProtocol,
        fixture: some ExprSyntaxProtocol,
        unappliedMethodReference: some ExprSyntaxProtocol
    ) -> Self {
        MacroExpansionExprSyntax(macro: "register", leftParen: .leftParenToken(), rightParen: .rightParenToken()) {
            TupleExprElementSyntax(
                label: nil,
                expression: type
            )

            TupleExprElementSyntax(
                label: "in",
                expression: fixture
            )

            TupleExprElementSyntax(
                label: "using",
                expression: unappliedMethodReference
            )
        }
    }
}
