import SwiftSyntax
import SwiftSyntaxBuilder

extension ClosureExprSyntax {
    init(
        simpleInput: ClosureShorthandParameterListSyntax,
        @CodeBlockItemListBuilder statementsBuilder: () throws -> CodeBlockItemListSyntax
    ) rethrows {
        self.init(
            signature: ClosureSignatureSyntax(
                leadingTrivia: .space,
                parameterClause: .simpleInput(simpleInput)
            ),
            statements: try statementsBuilder()
        )
    }
}
