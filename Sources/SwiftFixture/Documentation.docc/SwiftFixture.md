# ``SwiftFixture``

A simple framework for managing test fixtures in Swift.

## Overview

SwiftFixture provides a set of tools designed to help make it easy for you to instantiate and organise values of your own Swift types for use as fixtures during unit testing.

To recap, a [test fixture](https://en.wikipedia.org/wiki/Test_fixture) is an environment used to consistently test our software. For example:

```swift
struct User {
    var id: UUID
    var name: String
    var createdAt: Date
    var isActive: Bool
    // ...
}

class SummaryTests: XCTestCase {
    func testSummaryForActiveUser() {
        let user = User(id: UUID(), name: "John", createdAt: Date(), isActive: true)

        let actual = getSummary(for: user)
        let expected = "John is currently active"

        XCTAssertEqual(actual, expected)
    }
}
```

In the `testSummaryForActiveUser()` example above, the `user` property is our test fixture that we rely on to test the behaviour of the `getSummary(for:)` method. Using the existing `User` initializer directly to create the fixture works, but over time you might start running into issues as your codebase matures. 

For example, you might already have noticed that the test is forced to reference the unused `id` and `createdAt` arguments. Additionally, if this practice was applied in multiple places, adding a new argument to the `User` initializer would require a large number of code changes across your tests, or worse, you could find yourself taking shortcuts with default values when you don't want to be. 

SwiftFixture aims to help provide a structure for creating fixtures that can scale with your codebase as it grows:

```swift
class SummaryTests: XCTestCase {
    let fixture = Fixture()

    func testSummaryForActiveUser() throws {
        var user = try fixture(User.self)
        user.isActive = true

        let actual = getSummary(for: user)
        let expected = "\(user.name) is currently active"

        XCTAssertEqual(actual, expected)
    }
}
```


## Topics

### Essentials

- ``Fixture``

### Registering Custom Types 

- ``FixtureProviding``
- ``ProvideFixture()``

### Misc

- ``PreferredFormat``
- ``ResolutionError``
