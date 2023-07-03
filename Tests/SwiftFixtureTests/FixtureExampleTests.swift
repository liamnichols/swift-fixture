import SwiftFixture
import XCTest

private struct User: Equatable {
    let id: Int
    let name: String
    let createdAt: Date
}

private struct Item: Equatable {
    let title: String
    let owner: User
}

#if compiler(>=5.9)
@ProvideFixture
private struct Group {
    let id: UUID
    let title: String
}

private struct Office: FixtureProviding {
    let id: UUID
    let name: String
    let staff: [User]

    static func provideFixture(using values: ValueProvider) throws -> Office {
        #initFixture(using: values, with: Office.init(id:name:staff:))
    }
}
#endif

final class FixtureExampleTests: XCTestCase {
    let fixture = Fixture()

    override func setUp() {
        super.setUp()

        fixture.register(User.self) { values in
            User(
                id: try values.get("id"),
                name: try values.get("name"),
                createdAt: try values.get("createdAt")
            )
        }

        fixture.register(Item.self) { values in
            Item(
                title: try values.get("title"),
                owner: try values.get("owner")
            )
        }
    }

    func testExample() throws {
        let title = "Custom Title"
        let item: Item = try fixture(title: title)
        // ▿ SwiftFixtureTests.Item
        //   - title: "Custom Title"
        //   ▿ owner: SwiftFixtureTests.User
        //     - id: 6001929140874424963
        //     - name: "95bc0c41-90e6-4ab7-a10a-cbef6ab47a25"
        //     ▿ createdAt: 2015-07-09 10:25:55 +0000
        //       - timeIntervalSinceReferenceDate: 458130355.29743665

        // ...
        XCTAssertNotNil(item)
        XCTAssertEqual(item.title, title)
    }

    func testArray() throws {
        let items: [Date] = Array(repeating: try fixture(), count: 3)
        XCTAssertEqual(items.count, 3)
    }

    #if compiler(>=5.9)
    func testProvideFixtureMacro() throws {
        let title = "Group Fixture"
        let group: Group = try fixture(title: title)

        XCTAssertEqual(group.title, title)
    }

    func testInitFixtureMacro() throws {
        let office: Office = try fixture(name: "Bristol")

        XCTAssertEqual(office.name, "Bristol")
    }
    #endif
}
