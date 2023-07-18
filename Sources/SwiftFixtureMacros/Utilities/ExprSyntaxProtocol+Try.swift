import SwiftSyntax

extension ExprSyntaxProtocol {
    func wrapInTry(_ wrapInTry: Bool = true) -> ExprSyntaxProtocol {
        if wrapInTry {
            return TryExprSyntax(expression: self)
        } else {
            return self
        }
    }
}
