# Testing With SwiftFixture

Using ``Fixture`` to level up your unit tests

## Overview

SwiftFixture helps you manage test fixtures for your unit tests. A [test fixture](https://en.wikipedia.org/wiki/Test_fixture) is a broad term that describes an environment used for consistently testing your software, but in this context, we're referring to specific representations of your Swift types.

As an example, lets imagine that you want to write a test for the following method:

```swift
struct User {
    let id: UUID
    let name: String
    let createdAt: Date
    let isActive: Bool
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

Finally, as your models get more complex, you find that your test gets bloated with code purely to construct the fixture in a way that satisfies the initializer requirements. Even in the example above, our test only depends on the `name` and `isActive` property yet we find ourselves having to specify a value to `id` and `createdAt` anyway. It doesn't take long for things to get out of hand.

SwiftFixture aims to standardize the creation of fixtures in a consistent way with the smallest footprint possible in your test code.

```swift
import SwiftFixture

class SummaryTests: XCTestCase {
    let fixture = Fixture()

    func testSummaryForActiveUser() throws {
        let user: User = try fixture(isActive: true)

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
let fixture = Fixture()

let value: Int = try fixture() // Int.random(in:)
```

### Registering value providers

By default, providers for common system types (`Int`, `String`, `Bool`, `Date`, `UUID` etc) are provided, but support for your own types can be added by using the ``Fixture/register(_:provideValue:)-7fin6`` method:

```swift
let fixture = Fixture(preferredFormat: .constant)

fixture.register(User.self) { values in
    User(
        id: try values.get("id"), 
        name: try values.get("name"), 
        createdAt: try values.get("createdAt"), 
        isActive: try values.get("isActive")
    )
}

let value: User = try fixture() // User.init(id:name:createdAt:isActive:)
```

If a type hasn't been registered, the ``ResolutionError/noProviderRegisteredForType(_:)`` error will be thrown instead.

Alternatively, if you need to reuse a value provider across multiple `XCTestCase` subclasses, you can instead use the ``FixtureProviding`` protocol to allow reuse:

```swift
extension User: FixtureProviding {
    public static func provideFixture(using values: ValueProvider) throws -> Self {
        User(
            id: try values.get("id"), 
            name: try values.get("name"), 
            createdAt: try values.get("createdAt"), 
            isActive: try values.get("isActive")
        )
    }
}
```

The ``FixtureProviding/provideFixture(using:)`` method is used only when a value provider hasn't been registered for the same type using ``Fixture/register(_:provideValue:)-7fin6``.

### Overriding Values

In the example above, a `User` fixture is created by calling `try fixture(isActive: true)`, but how does this work?

``Fixture`` is a `@dynamicCallable` type which allows for zero or more arguments to be specified which are then passed into the ``ValueProvider`` instance used for resolving fixture values. 

At the time of resolution, the call to ``ValueProvider/get(_:)`` uses the optional `label` argument to map a specific fixture argument to the argument used for resolution. 

It's recommended that you match the label used with the original initializer argument label to prevent confusion. The best way to do this is to use the ``ProvideFixture()`` macro which can provide automatic conformance to the ``FixtureProviding`` protocol for your types.

Because `fixture()` value resolution is dynamic, some element of type safety is lost at compile time, however ``Fixture`` will throw errors at runtime if you specify a mismatching value type for an argument, or if you specify and argument that is not actually used as part of the fixture.
