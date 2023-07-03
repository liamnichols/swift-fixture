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

try fixture() as Int
// - 5363896279182060614

try fixture() as Date
// ▿ 2008-09-10 18:34:13 +0000
// - timeIntervalSinceReferenceDate: 242764453.45139748

try fixture() as String
// - "1b3e9b17-d79a-4056-8f2b-73112694fa5c"
```

By default, values produced by ``Fixture`` are done so in a non-deterministic way to encourage [constrained non-determinism](https://blog.ploeh.dk/2009/03/05/ConstrainedNon-Determinism/). This is done to help encourage you to rely less on hardcoded values for expected results as you let SwiftFixture handle things for you.

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

let value: User = try fixture()
// ▿ User
//   ▿ id: 27310087-1F15-4033-B97B-9E6873B48918
//     - uuid: "27310087-1F15-4033-B97B-9E6873B48918"
//   - name: "1b3e9b17-d79a-4056-8f2b-73112694fa5c"
//   ▿ createdAt: 2012-05-24 21:13:02 +0000
//     - timeIntervalSinceReferenceDate: 359586782.8698358
//   - isActive: false
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

In addition to creating fixtures entirely with non-deterministic placeholder values, it is not uncommon to want to need to control specific properties. From the `testSummaryForActiveUser()` example above, the `isActive` property needs to always be set to `true` when the test runs:

```swift
let user: User = try fixture(isActive: true)
// ▿ User
//   ▿ id: 27310087-1F15-4033-B97B-9E6873B48918
//     - uuid: "27310087-1F15-4033-B97B-9E6873B48918"
//   - name: "1b3e9b17-d79a-4056-8f2b-73112694fa5c"
//   ▿ createdAt: 2012-05-24 21:13:02 +0000
//     - timeIntervalSinceReferenceDate: 359586782.8698358
//   - isActive: true
```

This works because ``Fixture`` allows for a dynamic set of arguments to be specified. If the label of an argument matches the label passed into ``ValueProvider``'s ``ValueProvider/get(_:)`` method when producing a fixture, the argument is used instead of a placeholder value.

It's recommended that you match the label used with the original initializer argument label to prevent confusion. The best way to do this is to use the ``ProvideFixture()`` macro which can provide automatic conformance to the ``FixtureProviding`` protocol for your types.

Because `fixture()` value resolution is dynamic, some element of type safety is lost at compile time, however ``Fixture`` will throw errors at runtime if you specify a mismatching value type for an argument, or if you specify and argument that is not actually used as part of the fixture.
