import SwiftFixtureMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class FixtureMacroTests: XCTestCase {
    func testFixture() throws {
        assertMacroExpansion(
            """
            let fixture = #fixture(
                User.init(foo:bar:),
                Group.init(id:owner:members:)
            )
            """,
            expandedSource: """
            let fixture = {
                let fixture = Fixture()
                fixture.register(User.self) { values in
                    User(
                        foo: try values.get("foo"),
                        bar: try values.get("bar")
                    )
                }
                fixture.register(Group.self) { values in
                    Group(
                        id: try values.get("id"),
                        owner: try values.get("owner"),
                        members: try values.get("members")
                    )
                }
                return fixture
            }()
            """,
            macros: testMacros
        )
    }
}
