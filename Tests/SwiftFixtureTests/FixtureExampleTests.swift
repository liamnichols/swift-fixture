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

        fixture.register(User.self) { fixture in
            User(id: try fixture(), name: try fixture(), createdAt: try fixture())
        }
        fixture.register(Item.self) { fixture in
            Item(title: try fixture(), owner: try fixture())
        }
    }

    func testExample() throws {
        let item: Item = try fixture()
        // ▿ SwiftFixtureTests.Item
        //   - title: "f691a87e-1a93-4fea-b139-c1e0847df514"
        //   ▿ owner: SwiftFixtureTests.User
        //     - id: 6001929140874424963
        //     - name: "95bc0c41-90e6-4ab7-a10a-cbef6ab47a25"
        //     ▿ createdAt: 2015-07-09 10:25:55 +0000
        //       - timeIntervalSinceReferenceDate: 458130355.29743665

        // ...
        XCTAssertNotNil(item)
    }

    func testArray() throws {
        let items: [Date] = try fixture(count: 3)
        // ▿ 3 elements
        //   ▿ 2010-02-04 03:30:59 +0000
        //     - timeIntervalSinceReferenceDate: 286947059.05920434
        //   ▿ 2016-04-23 21:02:54 +0000
        //     - timeIntervalSinceReferenceDate: 483138174.7929988
        //   ▿ 2007-04-23 09:55:57 +0000
        //     - timeIntervalSinceReferenceDate: 199014957.40783462

        // ...
        XCTAssertEqual(items.count, 3)
    }
}
