# SwiftFixture

[![Test Status](https://github.com/liamnichols/swift-fixture/workflows/Tests/badge.svg)](https://github.com/liamnichols/swift-fixture/actions/workflows/tests.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fliamnichols%2Fswift-fixture%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/liamnichols/swift-fixture)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fliamnichols%2Fswift-fixture%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/liamnichols/swift-fixture)

A simple framework for managing test fixtures in Swift.

- [Overview](#overview)
- [Why?](#why)
- [How?](#how)
- [Inspiration](#inspiration)

## Overview

SwiftFixture provides a set of tools designed to help make it easy for you to instantiate and organize values of your own Swift types for use as fixtures during unit testing.

```swift
@ProvideFixture
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

```swift
class UserTests: XCTestCase {
    let fixture = Fixture()
    
    func testSummaryForActiveUser() throws {
        let user: User = try fixture(isActive: true)
        
        XCTAssertEqual(getSummary(for: user), "\(user.name) is active!")
    }
}
```

## Why?

Almost every unit test will need a fixture. Put simply, a fixture is just a piece of information that controls the environment of the test. When testing Swift code, instances of your types are your fixtures, like `user` in the above example.

With every unit test written, you will find yourself needing to initialize values more and more. This can start to become repetitive and as your projects grow in complexity, it's likely that the initializer argument list also grows. It's not uncommon to eventually find yourself writing something like this:

```swift
func testStateForSubscribedUser() {
    let user = User(
        id: UUID(),
        name: "ksdf",
        itemCount: 0,
        createdAt: Date(),
        subscription: Subscription(
            id: UUID(),
            startedAt: Date(),
            expires: Date(),
            paymentMethod: .iap,
            referralCode: nil
        ),
        profileState: .complete,
        avatar: nil
    )
    
    XCTAssertEqual(user.state, .subscribed)
}

func testStateForUserWithoutSubscription() {
    let user = User(
        id: UUID(),
        name: "ksdf",
        itemCount: 0,
        createdAt: Date(),
        subscription: nil,
        profileState: .complete,
        avatar: nil
    )
    
    XCTAssertEqual(user.state, .unsubscribed)
}

func testStateForUserWithExpiredSubscription() {
    let user = User(
        id: UUID(),
        name: "ksdf",
        itemCount: 0,
        createdAt: Date(),
        subscription: Subscription(
            id: UUID(),
            startedAt: Date(timeIntervalSinceReferenceDate: 0),
            expires: Date(timeIntervalSinceNow: -10),
            paymentMethod: .iap,
            referralCode: nil
        ),
        profileState: .complete,
        avatar: nil
    )
    
    XCTAssertEqual(user.state, .expired)
}
```

The three _simple_ tests above end up using a lot more code than they really needed and overall things end up pretty noisy. Additionally, making unrelated changes to `User` such as adding a new property require that we go back and add a new default value to each instance we initialize when that property shouldn't even have been associated with this test in the first place.

With a few helper methods, you can certainly improve this a bit, but it can be hard to do so consistently when you end up having to write your own helpers. Furthermore, it is also very tempting to do things that influence your production code, such as providing default values on the main initializer.

SwiftFixture is designed to worry about all of this so that you don't have to.

## How?

Check out the [the documentation](https://swiftpackageindex.com/liamnichols/swift-fixture/main/documentation/swiftfixture) for guidance using SwiftFixture.

## Inspiration

This library was inspired by [KFixture](https://github.com/FlexTradeUKLtd/kfixture), a Kotlin wrapper around [JFixture](https://github.com/FlexTradeUKLtd/jfixture) (inspired by [AutoFixture](AutoFixture)).
