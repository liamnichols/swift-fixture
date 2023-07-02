import SwiftFixture
import XCTest

struct User: Equatable {
    let id: Int
    let name: String
    let createdAt: Date
}

struct Item: Equatable {
    let title: String
    let owner: User
}

final class FixtureExampleTests: XCTestCase {
    let fixture = Fixture(preferredFormat: .random)

    override func setUp() {
        super.setUp()

        fixture.register(User.self) { values in
            User(
                id: try values.value(labelled: "id"),
                name: try values.value(labelled: "name"),
                createdAt: try values.value(labelled: "createdAt")
            )
        }

        fixture.register(Item.self) { values in
            Item(
                title: try values.value(labelled: "title"),
                owner: try values.value(labelled: "owner")
            )
        }
    }

    func testExample() throws {
        let item: Item = try fixture(title: "Custom Title")
        // ▿ SwiftFixtureTests.Item
        //   - title: "Custom Title"
        //   ▿ owner: SwiftFixtureTests.User
        //     - id: 6001929140874424963
        //     - name: "95bc0c41-90e6-4ab7-a10a-cbef6ab47a25"
        //     ▿ createdAt: 2015-07-09 10:25:55 +0000
        //       - timeIntervalSinceReferenceDate: 458130355.29743665

        // ...
        XCTAssertNotNil(item)
        XCTAssertEqual(item.title, "Custom Title")
    }

    func testArray() throws {
        let items: [Date] = Array(repeating: try fixture(), count: 3)
        XCTAssertEqual(items.count, 3)
    }
}
