import SwiftSyntax
import SwiftSyntaxBuilder

extension FunctionCallExprSyntax {
    public init<C: ExprSyntaxProtocol>(
        callee: C,
        leftParen: TokenSyntax = .leftParenToken(),
        rightParen: TokenSyntax,
        @TupleExprElementListBuilder argumentList: () -> TupleExprElementListSyntax = { [] }
    ) {
        self.init(
            calledExpression: callee,
            leftParen: leftParen,
            argumentList: argumentList(),
            rightParen: rightParen
        )
    }
}

