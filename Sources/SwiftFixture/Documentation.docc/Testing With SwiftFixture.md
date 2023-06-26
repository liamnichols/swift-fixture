# Testing With SwiftFixture

Using ``Fixture`` to level up your unit tests

## Overview

SwiftFixture helps you manage test fixtures for your unit tests. A [test fixture](https://en.wikipedia.org/wiki/Test_fixture) is a broad term that describes an environment used for consistently testing your software, but in this context, we're referring to specific representations of your Swift types.

As an example, lets imagine that you want to write a test for the following method:

```swift
struct User {
    var id: UUID
    var name: String
    var createdAt: Date
    var isActive: Bool
}

func getSummary(for user: User) -> String {
    if user.isActive {
        return "\(user.name) is currently active!"
    } else {
        return "\(user.name) is not active."
    }
}
```

To test the return value of this method, you need to pass an instance of the `User` type. The instance that you create and pass into the `getSummary(for:)` would be the fixture used to provide the environment that you use to test the method. You can create this fixture just like you create any other instance:

```swift
class SummaryTests: XCTestCase {
    func testSummaryForActiveUser() {
        let user = User(
            id: UUID(), 
            name: "John", 
            createdAt: Date(), 
            isActive: true
        )

        let actual = getSummary(for: user)
        let expected = "John is currently active!"

        XCTAssertEqual(actual, expected)
    }
}
```

This test is great. But over time, this approach can become cumbersome to maintain. For example, if you add additional properties to `User`, you would then have to update every test where you initialize `User`, even if you didn't use the property in your test! 

As a shortcut, you might be tempted to just provide default values for your initializer arguments, but there might not always be a sensible default value and this could eventually leak into your production code which is likely not what you want.

Finally, as your models get more complex, you find that your test gets bloated with code purely to construct the fixture in a way that satisfies the initializer requirements. Even in the example above, our test only depends on the `name` and `isActive` property yet we find ourselves having to specify a value to `id` and `currentDate` anyway. It doesn't take long for things to get out of hand.

SwiftFixture aims to standardize the creation of fixtures in a consistent way with the smallest footprint possible in your test code.

```swift
import SwiftFixture

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

Using ``Fixture``, everything is taken care of for you. All you need to do is request a fixture for a given type and you are good to go. 

### Retrieving a fixture

The ``Fixture`` class has a primary callable interface used to obtain a fixture value for any given type:

```swift
let fixture = Fixture(preferredFormat: .random)

let value = try fixture(Int.self) // Int.random(in:)
```

### Registering value providers

By default, providers for common system types (`Int`, `String`, `Bool`, `Date`, `UUID` etc) are provided, but support for other types can be added by using the ``Fixture/register(_:provideValue:)-i0ea`` method:

```swift
let fixture = Fixture(preferredFormat: .constant)

fixture.register(User.self) { fixture in
    User(id: try fixture(), name: try fixture(), createdAt: try fixture(), isActive: try fixture())
}

let value = try fixture(User.self) // User.init(id:name:createdAt:isActive:)
```

If a type hasn't been registered, the ``ResolutionError`` type will instead be thrown. This is the only error thrown by ``Fixture`` itself, but your own value providers can also throw other errors as well (i.e if they relied on a throwable initializer).

Alternatively, if you need to reuse a value provider across multiple `XCTestCase` subclasses, you can instead use the ``FixtureProviding`` protocol to allow reuse:

```swift
extension User: FixtureProviding {
    public static func provideFixture(using fixture: Fixture) throws -> Self {
        User(id: try fixture(), name: try fixture(), createdAt: try fixture(), isActive: try fixture())
    }
}
```

The ``FixtureProviding/provideFixture(using:)`` method is used only when a value provider hasn't been registered for the same type using ``Fixture/register(_:provideValue:)-i0ea``. 
