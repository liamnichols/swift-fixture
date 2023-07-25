import SwiftFixtureMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class RegisterMacroTests: XCTestCase {
    func testRegister() throws {
        assertMacroExpansion(
            """
            let fixture: Fixture = {
                let f = Fixture()
                #register(MyType.self, in: f, using: MyType.init(foo:bar:)
                return f
            }()
            """,
            expandedSource: """
            let fixture: Fixture = {
                let f = Fixture()
                f.register(MyType.self) { values in
                    MyType(
                        foo: try values.get("foo"),
                        bar: try values.get("bar")
                    )
                }
                return f
            }()
            """,
            macros: testMacros
        )
    }
}
