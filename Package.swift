// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import Foundation
import PackageDescription

let package = Package(
    name: "SwiftFixture",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(name: "SwiftFixture", targets: ["SwiftFixture"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0" ..< "601.0.0-prerelease")
    ],
    targets: [
        .target(
            name: "SwiftFixture",
            dependencies: [
                .target(name: "SwiftFixtureMacros")
            ]
        ),
        .testTarget(
            name: "SwiftFixtureTests",
            dependencies: [
                .target(name: "SwiftFixture")
            ]
        ),

        .macro(
            name: "SwiftFixtureMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "SwiftFixtureMacrosTests",
            dependencies: [
                .target(name: "SwiftFixtureMacros"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        )
    ]
)

// https://swiftpackageindex.com/swiftpackageindex/spimanifest/0.19.0/documentation/spimanifest/validation
// On CI, we want to validate the manifest, but nobody else needs that.
if ProcessInfo.processInfo.environment.keys.contains("VALIDATE_SPI_MANIFEST") {
    package.dependencies.append(
       .package(url: "https://github.com/SwiftPackageIndex/SPIManifest.git", from: "0.12.0")
    )
}
