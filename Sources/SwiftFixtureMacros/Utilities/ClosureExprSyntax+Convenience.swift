import SwiftSyntax
import SwiftSyntaxBuilder

extension ClosureExprSyntax {
    init(
        simpleInput: ClosureParamListSyntax,
        @CodeBlockItemListBuilder statementsBuilder: () throws -> CodeBlockItemListSyntax
    ) rethrows {
        self.init(
            signature: ClosureSignatureSyntax(
                leadingTrivia: .space,
                input: .simpleInput(simpleInput)
            ),
            statements: try statementsBuilder()
        )
    }
}
