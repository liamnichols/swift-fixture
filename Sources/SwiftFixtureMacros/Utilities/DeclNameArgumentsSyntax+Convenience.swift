import SwiftSyntax

extension DeclNameArgumentsSyntax {
    var labels: [String?] {
        arguments.map { argument in
            switch argument.name.tokenKind {
            case .wildcard:
                return nil
            case .identifier(let label):
                return label
            default:
                fatalError("unexpected token kind in decl arguments list")
            }
        }
    }
}
