// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
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

// https://swiftpackageindex.com/swiftpackageindex/spimanifest/0.19.0/documentation/spimanifest/validation
// On CI, we want to validate the manifest, but nobody else needs that.
if ProcessInfo.processInfo.environment.keys.contains("VALIDATE_SPI_MANIFEST") {
    package.dependencies.append(
       .package(url: "https://github.com/SwiftPackageIndex/SPIManifest.git", from: "0.12.0")
    )
}
