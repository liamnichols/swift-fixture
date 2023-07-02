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

        static func provideFixture(using values: ValueProvider) throws -> Container {
            Container(id: try values.value(labelled: "id"), name: try values.value(labelled: "name"))
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
        fixture.register(TestModel.self) { values in
            TestModel(
                string: try values.value(labelled: "string"),
                date: try values.value(labelled: "date"),
                boolean: try values.value(labelled: "boolean"),
                enumeration: try values.value(labelled: "enumeration"),
                unregisteredType: try values.value(labelled: "unregisteredType")
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
