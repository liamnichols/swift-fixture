import XCTest
@testable import SwiftFixture

final class FixtureTests: XCTestCase {
    struct UnregisteredType: Equatable {
    }

    enum EmptyEnum: CaseIterable, Equatable {
    }

    struct TestRawRepresentable: RawRepresentable, Equatable {
        let rawValue: UnregisteredType
    }

    struct StringRepresentable: RawRepresentable, Equatable {
        let rawValue: String
    }

    enum TestEnum: CaseIterable, Equatable {
        case one, two, three
    }

    struct TestModel: Equatable {
        let string: String
        let date: Date
        let boolean: Bool
        let enumeration: TestEnum
        let stringRepresentable: StringRepresentable
        let unregisteredType: UnregisteredType?
    }

    func testFixture() throws {
        let fixture = Fixture()
        fixture.register(Int.self) { 42 }
        fixture.register(String.self) { "foo" }
        fixture.register(TestEnum.self) { .three }

        // Regular Value
        XCTAssertEqual(try fixture(Int.self), 42)
        XCTAssertEqual(try fixture(StringRepresentable.self), StringRepresentable(rawValue: "foo"))
        XCTAssertEqual(try fixture(TestEnum.self), .three)

        // Optional
        XCTAssertEqual(try fixture(Int?.self), 42)
        XCTAssertEqual(try fixture(StringRepresentable?.self), StringRepresentable(rawValue: "foo"))
        XCTAssertEqual(try fixture(TestEnum?.self), .three)
    }

    func testValue() {
        let fixture = Fixture()
        fixture.register(Int.self) { 42 }

        XCTAssertEqual(try fixture.value(for: Int.self), 42)
    }

    func testValue_throwsIfNotRegistered() {
        let fixture = Fixture()

        XCTAssertThrowsError(try fixture.value(for: FixtureTests.self)) { error in
            XCTAssertTrue(error is ResolutionError)
        }
    }

    func testValue_overload_rawRepresentable() {
        let fixture = Fixture()
        fixture.register(String.self) { "foo" }

        XCTAssertEqual(try fixture.value(for: StringRepresentable.self), StringRepresentable(rawValue: "foo"))
    }

    func testValue_overload_rawRepresentable_prioritisesRegisteredProvider() {
        let fixture = Fixture()
        fixture.register(StringRepresentable.self) { StringRepresentable(rawValue: "bar") }

        XCTAssertEqual(try fixture.value(for: StringRepresentable.self), StringRepresentable(rawValue: "bar"))
    }

    func testValue_overload_caseIterable() {
        let fixture = Fixture()

        XCTAssertNoThrow(try fixture.value(for: TestEnum.self))
    }

    func testValue_overload_caseIterable_prioritisesRegisteredProvider() {
        let fixture = Fixture()
        fixture.register(TestEnum.self) { .two }

        XCTAssertEqual(try fixture.value(for: TestEnum.self), .two)
    }

    func testValue_optional() {
        let fixture = Fixture()
        fixture.register(Int.self) { 42 }
        fixture.register(String.self) { "foo" }
        fixture.register(TestEnum.self) { .three }

        XCTAssertEqual(try fixture.value(for: Int?.self), 42)
        XCTAssertEqual(try fixture.value(for: StringRepresentable?.self), StringRepresentable(rawValue: "foo"))
        XCTAssertEqual(try fixture.value(for: TestEnum?.self), .three)
    }

    func testValue_optional_usesNilIfNoValueFound() {
        let fixture = Fixture()

        XCTAssertNil(try fixture.value(for: UnregisteredType?.self))
        XCTAssertNil(try fixture.value(for: TestRawRepresentable?.self))
        XCTAssertNil(try fixture.value(for: EmptyEnum?.self))
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
                stringRepresentable: try fixture(),
                unregisteredType: try fixture()
            )
        }

        let model: TestModel = try fixture()
        XCTAssertEqual(model, TestModel(
            string: "",
            date: Date(timeIntervalSinceReferenceDate: 0),
            boolean: false,
            enumeration: .one,
            stringRepresentable: .init(rawValue: ""),
            unregisteredType: nil
        ))
    }
}
