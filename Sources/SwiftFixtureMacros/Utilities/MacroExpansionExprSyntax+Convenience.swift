import SwiftSyntax

extension MacroExpansionExprSyntax {
    static func initFixture(
        valueProvider: some ExprSyntaxProtocol,
        unappliedMethodReference: some ExprSyntaxProtocol
    ) -> Self {
        MacroExpansionExprSyntax(macroName: "initFixture", leftParen: .leftParenToken(), rightParen: .rightParenToken()) {
            LabeledExprSyntax(
                label: "with",
                expression: valueProvider
            )

            LabeledExprSyntax(
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
        MacroExpansionExprSyntax(macroName: "register", leftParen: .leftParenToken(), rightParen: .rightParenToken()) {
            LabeledExprSyntax(
                label: nil,
                expression: type
            )

            LabeledExprSyntax(
                label: "in",
                expression: fixture
            )

            LabeledExprSyntax(
                label: "using",
                expression: unappliedMethodReference
            )
        }
    }
}
