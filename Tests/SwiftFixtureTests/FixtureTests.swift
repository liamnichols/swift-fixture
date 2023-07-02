import XCTest
@testable import SwiftFixture

final class FixtureTests: XCTestCase {
    struct UnregisteredType: Equatable {
    }
    
    enum EmptyEnum: CaseIterable, Equatable {
    }
    
    enum TestEnum: CaseIterable, Equatable {
        case one, two, three
    }
    
    struct Container: Equatable, FixtureProviding {
        let id: Int
        let name: String

        static func provideFixture(using fixture: Fixture) throws -> Container {
            Container(id: try fixture(), name: try fixture())
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

        // Optional
        XCTAssertEqual(try fixture() as Int?, 42)
        XCTAssertEqual(try fixture() as TestEnum?, .three)
        XCTAssertEqual(try fixture() as Container?, .init(id: 42, name: "foo"))

        // Unregistered
        XCTAssertEqual(try fixture() as UnregisteredType?, nil)
        XCTAssertThrowsError(try fixture() as UnregisteredType) { error in
            XCTAssertTrue(error is ResolutionError)
        }
    }

    func testRegisteredModel() throws {
        let fixture = Fixture(preferredFormat: .constant)
        fixture.register(TestEnum.self) { .one }
        fixture.register(TestModel.self) { fixture in
            TestModel(
                string: try fixture(),
                date: try fixture(),
                boolean: try fixture(),
                enumeration: try fixture(),
                unregisteredType: try fixture()
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

    func testArray() {
        let fixture = Fixture()
        var value = 0
        fixture.register(Int.self) {
            value += 1
            return value
        }

        XCTAssertEqual(try fixture(count: 3) as [Int], [1, 2, 3])
        XCTAssertEqual(try fixture(count: 3) as [Int]?, [4, 5, 6])
    }
}
