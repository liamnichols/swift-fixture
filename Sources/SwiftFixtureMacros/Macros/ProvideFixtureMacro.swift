import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftDiagnostics
import SwiftSyntaxMacros

public struct ProvideFixtureMacro: ExtensionMacro {
    /// A type that describes the initializer to be called in the `FixtureProviding.provideFixture(using:)` implementation
    struct InitializerContext {
        let typeIdentifier: TokenSyntax
        let unappliedMethodReference: MemberAccessExprSyntax
        let isThrowing: Bool
    }

    public static func expansion<D: DeclGroupSyntax, T: TypeSyntaxProtocol, C: MacroExpansionContext>(
        of node: AttributeSyntax,
        attachedTo declaration: D,
        providingExtensionsOf type: T,
        conformingTo protocols: [TypeSyntax],
        in context: C
    ) throws -> [ExtensionDeclSyntax] {
        // If there is an explicit conformance to FixtureProviding already, don't add one.
//        if protocols.isEmpty {
//            return []
//        }

        // Discover the context to be used for this declaration
        let context = try initializerContext(for: declaration)

        // Define the values property
        let valuesId = DeclReferenceExprSyntax(baseName: "values")

        // Return the extension
        // extension MyType: FixtureProviding { ... }
        return [
            try ExtensionDeclSyntax("extension \(type.trimmed): FixtureProviding") {
                // public static func provideFixture(using values: ValueProvider) throws -> Self { ... }
                try FunctionDeclSyntax(
                    "public static func provideFixture(using \(valuesId): ValueProvider) throws -> \(context.typeIdentifier)"
                ) {
                    // #initFixture(with: values, using: TheType.init(foo:bar:))
                    try InitFixtureMacro.expansion(
                        valueProvider: valuesId,
                        unappliedMethodReference: try context.unappliedMethodReference.unappliedMethodReference
                    )
                    .wrapInTry(context.isThrowing) // try #initFixture(...)
                }
            }
        ]
    }
}

// MARK: - Arguments
private extension ProvideFixtureMacro {
    static func initializerContext(for declaration: some DeclGroupSyntax) throws -> InitializerContext {
        // Find all initializers in the declaration
        let typeIdentifier = try typeIdentifier(from: declaration)
        let initializers = declaration.memberBlock.members
            .compactMap { $0.decl.as(InitializerDeclSyntax.self) }
            .map { InitializerContext(decl: $0, typeIdentifier: typeIdentifier) }

        // If there are none, and it's a struct, assume use of the memberwise init
        if initializers.isEmpty, let declaration = declaration.as(StructDeclSyntax.self) {
            return InitializerContext(
                typeIdentifier: typeIdentifier,
                name: .keyword(.`init`),
                argumentLabels: memberwiseInitializerArgumentLabels(for: declaration),
                isThrowing: false
            )
        }

        // Otherwise either return the initializer or throw the appropriate error
        switch initializers.count {
        case 1:
            return initializers.first!
        case 0:
            throw DiagnosticsError(diagnostics: [
                DiagnosticMessages.noInitializers.diagnose(at: declaration)
            ])
        default:
            throw DiagnosticsError(diagnostics: [
                DiagnosticMessages.tooManyInitializers.diagnose(at: declaration)
            ])
        }
    }

    private static func memberwiseInitializerArgumentLabels(
        for declaration: StructDeclSyntax
    ) -> [String] {
        var labels: [String] = []

        for member in declaration.memberBlock.members {
            guard let variable = member.decl.as(VariableDeclSyntax.self) else { continue }

            // for let keywords without initializer values
            if variable.bindingSpecifier.tokenKind == .keyword(.let) {
                for binding in variable.bindings where binding.initializer == nil {
                    guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
                    labels.append(identifier.identifier.text)
                }
            }

            // for non-computed vars
            if variable.bindingSpecifier.tokenKind == .keyword(.var) {
                for binding in variable.bindings where binding.accessorBlock == nil {
                    guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
                    labels.append(identifier.identifier.text)
                }
            }
        }

        return labels
    }

    private static func typeIdentifier(from declaration: some DeclGroupSyntax) throws -> TokenSyntax {
        // Take the type identifier from the declaration
        let token = if let declaration = declaration.as(StructDeclSyntax.self) {
            declaration.name
        } else if let declaration = declaration.as(EnumDeclSyntax.self) {
            declaration.name
        } else if let declaration = declaration.as(ClassDeclSyntax.self) {
            declaration.name
        } else {
            throw DiagnosticsError(diagnostics: [
                DiagnosticMessages.unsupportedMember.diagnose(at: declaration)
            ])
        }

        // Return just the literal text to strip out any unwanted trivia
        return TokenSyntax(stringLiteral: token.text)
    }
}

// MARK: - Utils
private extension ProvideFixtureMacro.InitializerContext {
    init(
        typeIdentifier: TokenSyntax,
        name: TokenSyntax,
        argumentLabels: [String?],
        isThrowing: Bool
    ) {
        self.init(
            typeIdentifier: typeIdentifier,
            unappliedMethodReference: MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(baseName: typeIdentifier),
                declName: DeclReferenceExprSyntax(
                    baseName: .keyword(.`init`),
                    argumentNames: DeclNameArgumentsSyntax(
                        arguments: DeclNameArgumentListSyntax(argumentLabels.map { label in
                            if let label {
                                DeclNameArgumentSyntax(name: .identifier(label))
                            } else {
                                DeclNameArgumentSyntax(name: .wildcardToken())
                            }
                        })
                    )
                )
            ),
            isThrowing: isThrowing
        )
    }

    init(decl: InitializerDeclSyntax, typeIdentifier: TokenSyntax) {
        let isThrowing = decl.signature.effectSpecifiers?.throwsSpecifier != nil
        let argumentLabels: [String?] = decl.signature.parameterClause.parameters.map { parameter in
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
            name: .keyword(.`init`),
            argumentLabels: argumentLabels,
            isThrowing: isThrowing
        )
    }
}
