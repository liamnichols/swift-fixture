import SwiftFixtureMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class InitFixtureMacroTests: XCTestCase {
    func testInitFixture() throws {
        assertMacroExpansion(
            """
            static func provideValue(using values: ValueProvider) throws -> User {
                #initFixture(with: values, using: User.init(id:name:createdAt:isActive:))
            }
            """,
            expandedSource: """
            static func provideValue(using values: ValueProvider) throws -> User {
                User(
                    id: try values.get("id"),
                    name: try values.get("name"),
                    createdAt: try values.get("createdAt"),
                    isActive: try values.get("isActive")
                )
            }
            """,
            macros: testMacros
        )
    }

    func testInitFixtureWithStaticMethodCall() {
        assertMacroExpansion(
            """
            static func provideValue(using values: ValueProvider) throws -> User {
                try #initFixture(with: values, using: User.newUser(name:))
            }
            """,
            expandedSource: """
            static func provideValue(using values: ValueProvider) throws -> User {
                try User.newUser(
                    name: try values.get("name")
                )
            }
            """,
            macros: testMacros
        )
    }

    func testInitFixtureWithUnlabelledArguments() {
        assertMacroExpansion(
            """
            static func provideValue(using values: ValueProvider) throws -> User {
                try #initFixture(with: values, using: User.init(name:_:_:age:))
            }
            """,
            expandedSource: """
            static func provideValue(using values: ValueProvider) throws -> User {
                try User(
                    name: try values.get("name"),
                    try values.get(),
                    try values.get(),
                    age: try values.get("age")
                )
            }
            """,
            macros: testMacros
        )
    }

    func testInitFixtureWithoutDeclNameArgs() {
        assertMacroExpansion(
            """
            static func provideValue(using values: ValueProvider) throws -> User {
                try #initFixture(with: values, using: User.init)
            }
            """,
            expandedSource: """
            static func provideValue(using values: ValueProvider) throws -> User {
                try #initFixture(with: values, using: User.init)
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Declaration name argument list must be provided",
                    line: 1,
                    column: 44
                )
            ],
            macros: testMacros
        )
    }

    func testInitFixtureWithoutMemberAccessExpBaseName() {
        assertMacroExpansion(
            """
            static func provideValue(using values: ValueProvider) throws -> User {
                try #initFixture(with: values, using: .init(id:name:createdAt:isActive:))
            }
            """,
            expandedSource: """
            static func provideValue(using values: ValueProvider) throws -> User {
                try #initFixture(with: values, using: .init(id:name:createdAt:isActive:))
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Unapplied method reference must explicitly define the base type",
                    line: 1,
                    column: 35
                )
            ],
            macros: testMacros
        )
    }

    func testInitFixtureWithoutMemberAccessExpr() {
        assertMacroExpansion(
            """
            static func provideValue(using values: ValueProvider) throws -> User {
                try #initFixture(with: values, using: "wrong type")
            }
            """,
            expandedSource: """
            static func provideValue(using values: ValueProvider) throws -> User {
                try #initFixture(with: values, using: "wrong type")
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Argument must be an unapplied method reference for a static method or initializer",
                    line: 1,
                    column: 35
                )
            ],
            macros: testMacros
        )
    }
}
