import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ProvideFixtureMacro.self,
        InitFixtureMacro.self
    ]
}
