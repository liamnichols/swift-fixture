import SwiftSyntax
import SwiftSyntaxBuilder

extension FunctionCallExprSyntax {
    public init<C: ExprSyntaxProtocol>(
        callee: C,
        leftParen: TokenSyntax = .leftParenToken(),
        rightParen: TokenSyntax,
        @LabeledExprListBuilder argumentList: () -> LabeledExprListSyntax = { [] }
    ) {
        self.init(
            calledExpression: callee,
            leftParen: leftParen,
            arguments: argumentList(),
            rightParen: rightParen
        )
    }
}

