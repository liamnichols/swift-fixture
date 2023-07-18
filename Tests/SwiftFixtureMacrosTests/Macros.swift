import SwiftFixtureMacros
import SwiftSyntaxMacros

let testMacros: [String: Macro.Type] = [
    "ProvideFixture": ProvideFixtureMacro.self,
    "initFixture": InitFixtureMacro.self,
    "register": RegisterMacro.self,
    "fixture": FixtureMacro.self
]
