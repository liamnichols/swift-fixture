import SwiftFixtureMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ProvideFixtureMacroTests: XCTestCase {
    func testProvideFixture() {
        assertMacroExpansion(
            #"""
            @ProvideFixture
            struct Foo {
                let type = "constant"
                let bar1: Int, bar2: Int
                let baz: Bool
                var wham = 22.0

                var notBaz: Bool {
                    !baz
                }
            }
            """#,
            expandedSource: #"""

            struct Foo {
                let type = "constant"
                let bar1: Int, bar2: Int
                let baz: Bool
                var wham = 22.0

                var notBaz: Bool {
                    !baz
                }
            }

            extension Foo: FixtureProviding {
                public static func provideFixture(using values: ValueProvider) throws -> Foo {
                    Foo(
                        bar1: try values.get("bar1"),
                        bar2: try values.get("bar2"),
                        baz: try values.get("baz"),
                        wham: try values.get("wham")
                    )
                }
            }
            """#,
            macros: testMacros
        )
    }

    func testProvideFixtureUsingInitializer() {
        assertMacroExpansion(
            #"""
            @ProvideFixture
            class Foo {
                let bar: Int
                let baz: Bool

                init(_ bar: Int, wham: Bool) {
                    self.bar = bar
                    self.baz = wham
                }
            }
            """#,
            expandedSource: #"""

            class Foo {
                let bar: Int
                let baz: Bool

                init(_ bar: Int, wham: Bool) {
                    self.bar = bar
                    self.baz = wham
                }
            }

            extension Foo: FixtureProviding {
                public static func provideFixture(using values: ValueProvider) throws -> Foo {
                    Foo(
                        try values.get(),
                        wham: try values.get("wham")
                    )
                }
            }
            """#,
            macros: testMacros
        )
    }

    func testProvideFixtureUsingThrowingInitializer() {
        assertMacroExpansion(
            #"""
            @ProvideFixture
            class Foo: Decodable {
                let bar: Int
                let baz: Bool

                init(_ bar: Int, wham: Bool) throws {
                    self.bar = bar
                    self.baz = wham
                }
            }
            """#,
            expandedSource: #"""

            class Foo: Decodable {
                let bar: Int
                let baz: Bool

                init(_ bar: Int, wham: Bool) throws {
                    self.bar = bar
                    self.baz = wham
                }
            }

            extension Foo: FixtureProviding {
                public static func provideFixture(using values: ValueProvider) throws -> Foo {
                    try Foo(
                        try values.get(),
                        wham: try values.get("wham")
                    )
                }
            }
            """#,
            macros: testMacros
        )
    }

    func testProvideFixtureDiagnosticForMultipleInitializers() {
        assertMacroExpansion(
            #"""
            @ProvideFixture
            class Foo: Decodable {
                let bar: Int
                let baz: Bool

                init(_ bar: Int, wham: Bool) throws {
                    self.bar = bar
                    self.baz = wham
                }

                init(from decoder: Decoder) throws {
                    fatalError()
                }
            }
            """#,
            expandedSource: #"""
            
            class Foo: Decodable {
                let bar: Int
                let baz: Bool

                init(_ bar: Int, wham: Bool) throws {
                    self.bar = bar
                    self.baz = wham
                }

                init(from decoder: Decoder) throws {
                    fatalError()
                }
            }
            """#,
            diagnostics: [
                DiagnosticSpec(
                    message: "@ProvideFixture is unable to disambiguate between multiple initializers",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }

    func testProvideFixtureDiagnosticForNoInitializers() {
        assertMacroExpansion(
            #"""
            @ProvideFixture
            class Foo: Decodable {
                let bar: Int
                let baz: Bool
            }
            """#,
            expandedSource: #"""

            class Foo: Decodable {
                let bar: Int
                let baz: Bool
            }
            """#,
            diagnostics: [
                DiagnosticSpec(
                    message: "@ProvideFixture requires that at least one initializer is defined",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
    }
}
