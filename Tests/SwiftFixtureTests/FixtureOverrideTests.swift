import Foundation
import SwiftFixture
import XCTest

final class FixtureOverrideTests: XCTestCase {
    struct RegisteredSubject {
        let id: Int
        let name: String
    }

    struct ProvidingSubject: FixtureProviding {
        let id: Int
        let name: String

        static func provideFixture(using values: ValueProvider) throws -> Self {
            ProvidingSubject(
                id: try values.get("id"),
                name: try values.get("name")
            )
        }
    }

    let fixture = Fixture()

    override func setUp() {
        super.setUp()

        fixture.register(RegisteredSubject.self) { values in
            RegisteredSubject(
                id: try values.get("id"),
                name: try values.get("name")
            )
        }
    }

    func testRegisteredProvider() throws {
        let value: RegisteredSubject = try fixture(name: "John")

        XCTAssertEqual(value.name, "John")
    }

    func testRegisteredProvider_typeMismatch() throws {
        XCTAssertThrowsError(try fixture(name: 1) as RegisteredSubject) { error in
            XCTAssertTrue(error is ResolutionError)
            XCTAssertEqual(
                String(reflecting: error),
                "An override was provided as Int for the argument ‘name‘ but String was expected."
            )
        }
    }

    func testRegisteredProvider_unusedArguments() throws {
        XCTAssertThrowsError(try fixture(name: "John", unused: true) as RegisteredSubject) { error in
            XCTAssertTrue(error is ResolutionError)
            XCTAssertEqual(
                String(reflecting: error),
                "The argument ‘unused‘ was specified but is not used by the fixture for RegisteredSubject."
            )
        }
    }

    // MARK: FixtureProviding

    func testFixtureProviding() throws {
        let value: ProvidingSubject = try fixture(name: "John")

        XCTAssertEqual(value.name, "John")
    }

    func testFixtureProviding_typeMismatch() throws {
        XCTAssertThrowsError(try fixture(name: 1) as ProvidingSubject) { error in
            XCTAssertTrue(error is ResolutionError)
            XCTAssertEqual(
                String(reflecting: error),
                "An override was provided as Int for the argument ‘name‘ but String was expected."
            )
        }
    }

    func testFixtureProviding_unusedArguments() throws {
        XCTAssertThrowsError(try fixture(name: "John", unused: true) as ProvidingSubject) { error in
            XCTAssertTrue(error is ResolutionError)
            XCTAssertEqual(
                String(reflecting: error),
                "The argument ‘unused‘ was specified but is not used by the fixture for ProvidingSubject."
            )
        }
    }
}
