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
}
