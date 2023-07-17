import SwiftDiagnostics
import SwiftSyntax

extension DiagnosticMessage {
    func diagnose(
        at node: Syntax,
        position: AbsolutePosition? = nil,
        fixIts: [FixIt] = []
    ) -> Diagnostic {
        Diagnostic(node: node, position: position, message: self, fixIts: fixIts)
    }
    
    func diagnose(
        at node: some SyntaxProtocol,
        position: AbsolutePosition? = nil,
        fixIts: [FixIt] = []
    ) -> Diagnostic {
        Diagnostic(node: Syntax(node), position: position, message: self, fixIts: fixIts)
    }
}
