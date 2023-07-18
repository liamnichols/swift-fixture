# Using Macros

Using Swift's Macro system to make the most out of SwiftFixture

## Overview

SwiftFixture provides four macros to help make testing as simple as possible

- ``ProvideFixture()``
- ``fixture(_:)``
- ``register(_:in:using:)``
- ``initFixture(with:using:)``

You don't need to use all of these macros together. Each macro offers a different balance between convenience and flexibility that will be explained in this article.

### @ProvideFixture

The ``ProvideFixture()`` macro is the most straightforward macro to use. You attach it to your own types and it provides ``FixtureProviding`` conformance automatically for you:

```swift
import SwiftFixture

@ProvideFixture
struct User {
    var id: UUID
    var name: String
    var createdAt: Date
    var isActive: Bool
}
```

The downside of this macro however is that it must be attached to the type definition itself. This means that you need to link the SwiftFixture dependency to your main app/library targets which is far from ideal.

If this isn't a problem for you, this is the most simplest approach. But if you want to keep your fixture code contained within your test targets, consider using other macros such as ``fixture(_:)``.

### #fixture

The ``fixture(_:)`` macro is the second easiest macro to use. It's a freestanding expression macro that returns an instance of ``Fixture`` while also registering a series of custom types based only on the provided unapplied method references:

```swift
import SwiftFixture
import XCTest

final class MyTests: XCTestCase {
    let fixture = #fixture(
        User.init(id:name:createdAt:isActive:),
        Group.init(id:owner:members:),
        // ...
    )
}
```

Instead of calling ``Fixture/register(_:provideValue:)-7fin6`` explicitly in the `setUp()` method for each of your own types, the macro produces code that does exactly this for you.

This macro works by parsing type and argument information from the (type checked) unapplied method reference. 

The benefit of this macro is that the code remains isolated within the test target however, it comes at a cost of having to keep the method references updated whenever you add, remove or move arguments that are referenced.

### #register

The ``register(_:in:using:)`` macro is used by ``fixture(_:)`` internally, but is also exposed for your convenience. It can be used to register additional types at a later point in time:

```swift
import SwiftFixture
import XCTest

final class MyTests: XCTestCase {
    let fixture = #fixture(...)

    func testSomething() {
        #register(Image.self, in: fixture, using: Image.init(id:url:))

        // ...
    }
}
```

### #initFixture 

The ``initFixture(with:using:)`` macro is also used internally by other macros but remains exposed for use within your own calls to ``Fixture/register(_:provideValue:)-7fin6`` or ``FixtureProviding/provideFixture(using:)``.

```swift
import SwiftFixture
import XCTest

extension User: FixtureProviding {
    static func provideFixture(using values: ValueProvider) throws -> User {
        #initFixture(with: values, using: User.init(id:name:createdAt:isActive:))
    }
}
```

You are much less likely to need to use this macro, but it does come in useful if you are using more mature tools such as Sourcery to generate code like the above across app/lib and test targets.
