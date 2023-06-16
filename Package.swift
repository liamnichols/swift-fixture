// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftFixture",
    products: [
        .library(name: "SwiftFixture", targets: ["SwiftFixture"])
    ],
    targets: [
        .target(name: "SwiftFixture"),
        .testTarget(name: "SwiftFixtureTests", dependencies: ["SwiftFixture"])
    ]
)
