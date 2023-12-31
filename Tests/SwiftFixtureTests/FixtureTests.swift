import XCTest
@testable import SwiftFixture

final class FixtureTests: XCTestCase {
    struct UnregisteredType: Hashable {
    }
    
    enum EmptyEnum: CaseIterable, Equatable {
    }
    
    enum TestEnum: CaseIterable, Equatable {
        case one, two, three
    }
    
    struct Container: Equatable, FixtureProviding {
        let id: Int
        let name: String

        static func provideFixture(using values: ValueProvider) throws -> Container {
            Container(id: try values.get("id"), name: try values.get("name"))
        }
    }

    struct TestModel: Equatable {
        let string: String
        let date: Date
        let boolean: Bool
        let enumeration: TestEnum
        let unregisteredType: UnregisteredType?
    }

    func testFixture() throws {
        let fixture = Fixture()
        fixture.register(Int.self) { 42 }
        fixture.register(String.self) { "foo" }
        fixture.register(TestEnum.self) { .three }

        // Regular Value
        XCTAssertEqual(try fixture() as Int, 42)
        XCTAssertEqual(try fixture() as TestEnum, .three)
        XCTAssertEqual(try fixture() as Container, .init(id: 42, name: "foo"))
        XCTAssertEqual(try fixture() as [Int], [42])
        XCTAssertEqual(try fixture() as Set<String>, ["foo"])
        XCTAssertEqual(try fixture() as [String: Int], ["foo": 42])

        // Optional
        XCTAssertEqual(try fixture() as Int?, 42)
        XCTAssertEqual(try fixture() as TestEnum?, .three)
        XCTAssertEqual(try fixture() as Container?, .init(id: 42, name: "foo"))
        XCTAssertEqual(try fixture() as [Int]?, [42])
        XCTAssertEqual(try fixture() as Set<String>?, ["foo"])
        XCTAssertEqual(try fixture() as [String: Int]?, ["foo": 42])

        // Unregistered
        XCTAssertEqual(try fixture() as UnregisteredType?, nil)
        XCTAssertEqual(try fixture() as [UnregisteredType], [])
        XCTAssertEqual(try fixture() as Set<UnregisteredType>, [])
        XCTAssertEqual(try fixture() as [String: UnregisteredType], [:])
        XCTAssertThrowsError(try fixture() as UnregisteredType) { error in
            XCTAssertTrue(error is ResolutionError)
        }
    }

    func testRegisteredModel() throws {
        let fixture = Fixture()
        fixture.register(String.self) { "" }
        fixture.register(Date.self) { Date(timeIntervalSinceReferenceDate: 0) }
        fixture.register(Bool.self) { false }
        fixture.register(TestEnum.self) { .one }
        fixture.register(TestModel.self) { values in
            TestModel(
                string: try values.get("string"),
                date: try values.get("date"),
                boolean: try values.get("boolean"),
                enumeration: try values.get("enumeration"),
                unregisteredType: try values.get("unregisteredType")
            )
        }

        let model: TestModel = try fixture()
        XCTAssertEqual(model, TestModel(
            string: "",
            date: Date(timeIntervalSinceReferenceDate: 0),
            boolean: false,
            enumeration: .one,
            unregisteredType: nil
        ))
    }
}
