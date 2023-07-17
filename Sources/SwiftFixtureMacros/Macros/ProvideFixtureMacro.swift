import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftDiagnostics
import SwiftSyntaxMacros

public struct ProvideFixtureMacro: MemberMacro, ConformanceMacro {
    /// A type that describes the initializer to be called in the `FixtureProviding.provideFixture(using:)` implementation
    struct InitializerContext {
        let typeIdentifier: TokenSyntax
        let argumentLabels: [String?]
        let isThrowing: Bool

        var unappliedMethodReference: MemberAccessExprSyntax {
            MemberAccessExprSyntax(
                base: IdentifierExprSyntax(identifier: typeIdentifier),
                name: .keyword(.`init`),
                declNameArguments: DeclNameArgumentsSyntax(
                    arguments: DeclNameArgumentListSyntax(argumentLabels.map { label in
                        if let label {
                            DeclNameArgumentSyntax(name: .identifier(label))
                        } else {
                            DeclNameArgumentSyntax(name: .wildcardToken())
                        }
                    })
                )
            )
        }
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Discover the initializer arguments
        let initializer = try initializerContext(for: declaration)

        // Create the provideFixture implementation calling through to the initialiser
        // public static func provideFixture(using values: ValueProvider) throws -> Self { ... }
        let functionDecl = try FunctionDeclSyntax(
            "public static func provideFixture(using values: ValueProvider) throws -> \(initializer.typeIdentifier)"
        ) {
            CodeBlockItemListSyntax {
                // #initFixture(with: values, using: TheType.init(foo:bar:))
                MacroExpansionExprSyntax(macro: "initFixture", leftParen: .leftParenToken(), rightParen: .rightParenToken()) {
                    TupleExprElementSyntax(
                        label: "with",
                        expression: IdentifierExprSyntax(identifier: "values")
                    )

                    TupleExprElementSyntax(
                        label: "using",
                        expression: initializer.unappliedMethodReference
                    )
                }
                .wrapInTry(initializer.isThrowing) // try #initFixture(...)
            }
        }

        return [
            DeclSyntax(functionDecl)
        ]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingConformancesOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        return [
            ("FixtureProviding", nil)
        ]
    }
}

// MARK: - Arguments
private extension ProvideFixtureMacro {
    static func initializerContext(for declaration: some DeclGroupSyntax) throws -> InitializerContext {
        // Find all initializers in the declaration
        let initializers = declaration.memberBlock.members.compactMap { $0.decl.as(InitializerDeclSyntax.self) }
        let typeIdentifier: TokenSyntax = "Self" // TODO: Try and figure out the actual type later?

        // If there are none, and it's a struct, assume use of the memberwise init
        if initializers.isEmpty, let declaration = declaration.as(StructDeclSyntax.self) {
            return InitializerContext(
                typeIdentifier: typeIdentifier,
                argumentLabels: memberwiseInitializerArgumentLabels(for: declaration),
                isThrowing: false
            )
        }

        // Otherwise build the context from the most appropriate initializer decl
        return InitializerContext(
            decl: try bestInitializer(from: initializers, in: declaration),
            typeIdentifier: typeIdentifier
        )
    }

    private static func bestInitializer(
        from initializers: [InitializerDeclSyntax],
        in declaration: some DeclGroupSyntax
    ) throws -> InitializerDeclSyntax {
        if initializers.isEmpty {
            throw DiagnosticsError(diagnostics: [
                ProvideFixtureDiagnostic.noInitializers.diagnose(at: declaration)
            ])
        } else if let initializer = initializers.first, initializers.count == 1 {
            return initializer
        }

        // If there are multiple options, either find the first initializer
        // TODO: Check for the marker as a reference to disambiguate
        throw DiagnosticsError(diagnostics: [
            ProvideFixtureDiagnostic.tooManyInitializers.diagnose(at: declaration)
        ])
    }

    private static func memberwiseInitializerArgumentLabels(
        for declaration: StructDeclSyntax
    ) -> [String] {
        var labels: [String] = []

        for member in declaration.memberBlock.members {
            guard let variable = member.decl.as(VariableDeclSyntax.self) else { continue }

            // for let keywords without initializer values
            if variable.bindingKeyword.tokenKind == .keyword(.let) {
                for binding in variable.bindings where binding.initializer == nil {
                    guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
                    labels.append(identifier.identifier.text)
                }
            }

            // for non-computed vars
            if variable.bindingKeyword.tokenKind == .keyword(.var) {
                for binding in variable.bindings where binding.accessor == nil {
                    guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
                    labels.append(identifier.identifier.text)
                }
            }
        }

        return labels
    }
}

// MARK: - Utils
private extension ExprSyntaxProtocol {
    func wrapInTry(_ wrapInTry: Bool = true) -> ExprSyntaxProtocol {
        if wrapInTry {
            return TryExprSyntax(expression: self)
        } else {
            return self
        }
    }
}

private extension ProvideFixtureMacro.InitializerContext {
    init(decl: InitializerDeclSyntax, typeIdentifier: TokenSyntax) {
        let isThrowing = decl.signature.effectSpecifiers?.throwsSpecifier != nil
        let argumentLabels: [String?] = decl.signature.input.parameterList.map { parameter in
            switch parameter.firstName.tokenKind {
            case .identifier(let label):
                return label
            case .wildcard:
                return nil
            default:
                // afaik, the external parameter label can only either be a wildcard or an identifier
                // TODO: Confirm if this code path is possible
                fatalError("Unexpected TokenKind \(parameter.firstName.tokenKind)")
            }
        }

        self.init(
            typeIdentifier: typeIdentifier,
            argumentLabels: argumentLabels,
            isThrowing: isThrowing
        )
    }
}
