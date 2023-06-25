// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftFixture",
    products: [
        .library(name: "SwiftFixture", targets: ["SwiftFixture"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
    ],
    targets: [
        .target(name: "SwiftFixture"),
        .testTarget(name: "SwiftFixtureTests", dependencies: ["SwiftFixture"])
    ]
)
