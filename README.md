# SwiftFixture

[![Test Status](https://github.com/liamnichols/swift-fixture/workflows/Tests/badge.svg)](https://github.com/liamnichols/swift-fixture/actions/workflows/tests.yml)
[![Swift Language Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fliamnichols%2Fswift-fixtures%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/liamnichols/swift-fixtures)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fliamnichols%2Fswift-fixtures%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/liamnichols/swift-fixtures)

SwiftFixture is a tool to help you in writing clean and concise unit tests by standardizing the creation of fixture values.

## Overview

With SwiftFixture, you can effortlessly instantiate values that are then passed into your test subject

```swift
func sum(_ numbers: Int...) -> Int {
    numbers.reduce(0, +)
}

let fixture = Fixture()

func testSum() throws {
    let number1 = try fixture(Int.self)
    let number2 = try fixture(Int.self)

    let expected = number1 + number2
    let actual = sum(number1, number2)

    XCTAssertEqual(expected, actual)
}
```

SwiftFixture can resolve values for a range of standard system types. By default, `Fixture` prefers randomness in values returned however, you can customize this behavior:

```swift
let fixture = Fixture(preferredFormat: .constant)

let value: Int = try fixture() // 0
```

Additionally, you can register your own providers to change the behavior of system type value resolution or to resolve fixtures for your own types:

```swift
let fixture = Fixture()

fixture.register(User.self) { fixture in
    User(
        id: try fixture(),
        name: try fixture(),
        isActive: try fixture(),
        createdAt: try fixture()
    )
}

let user = try fixture(User.self)
// ▿ User
//   ▿ id: C83AEAF9-EF48-4EEB-9684-EACA9AF2D6FE
//     - uuid: "C83AEAF9-EF48-4EEB-9684-EACA9AF2D6FE"
//   - name: "6b206c8d-3c4a-43b2-ac6a-5566e30c9f2d"
//   - isActive: false
//   ▿ createdAt: 2017-04-19 13:17:51 +0000
//     - timeIntervalSinceReferenceDate: 514300671.0827724
```

Registering custom providers (i.e in the `setUp()` method) helps keep your individual test methods concise since you don't need to directly invoke potentially lengthy initializers of objects with values that you don't actually care about purely to satisfy the compiler.

Alternatively, you can add conformance to the `FixtureProviding` protocol to avoid having to register types each time.

## Macro Support

As an alternative to manually registering each of your own types for use with `Fixture`, you can also use the `@ProvideFixture` macro (in Swift 5.9 or later) to generate conformance to the `FixtureProviding` protocol as follows:

```swift
import SwiftFixture

@ProvideFixture
struct User {
    let id: UUID
    let name: String
    let isActive: Bool
    let createdAt: Date
}
```

<details>
<summary><b>Expand Macro</b></summary>

```swift
import SwiftFixture

struct User {
    let id: UUID
    let name: String
    let isActive: Bool
    let createdAt: Date
    public static func provideFixture(using fixture: Fixture) throws -> Self {
        Self(id: try fixture(), name: try fixture(), isActive: try fixture(), createdAt: try fixture())
    }
}

extension User : FixtureProviding  {}
```

</details>

## Inspiration

This library was inspired by [KFixture](https://github.com/FlexTradeUKLtd/kfixture), a Kotlin wrapper around [JFixture](https://github.com/FlexTradeUKLtd/jfixture) (inspired by [AutoFixture](AutoFixture)).
