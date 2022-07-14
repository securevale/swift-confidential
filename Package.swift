// swift-tools-version: 5.6

import PackageDescription

var package = Package(
    name: "swift-confidential",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v15),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "ConfidentialKit",
            targets: ["ConfidentialKit"]
        )
    ],
    targets: [
        // Client Library
        .target(name: "ConfidentialKit"),

        // Tests
        .testTarget(
            name: "ConfidentialKitTests",
            dependencies: ["ConfidentialKit"]
        )
    ],
    swiftLanguageVersions: [.v5]
)

#if os(macOS)
package.dependencies.append(contentsOf: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-syntax.git", exact: "0.50600.1"),
    .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.9.0"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0")
])
package.targets.append(contentsOf: [
    // Core Module
    .target(
        name: "ConfidentialCore",
        dependencies: [
            "ConfidentialKit",
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            .product(name: "Parsing", package: "swift-parsing")
        ]
    ),

    // CLI Tool
    .executableTarget(
        name: "confidential",
        dependencies: [
            "ConfidentialCore",
            "Yams",
            .product(name: "ArgumentParser", package: "swift-argument-parser")
        ]
    ),

    // Tests
    .testTarget(
        name: "ConfidentialCoreTests",
        dependencies: ["ConfidentialCore"]
    )
])
#endif
