// swift-tools-version: 5.9

import PackageDescription

var package = Package(
    name: "swift-confidential",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v15),
        .watchOS(.v8),
        .tvOS(.v15),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "ConfidentialKit",
            targets: ["ConfidentialKit"]
        )
    ],
    targets: [
        // Client Library
        .target(
            name: "ConfidentialKit",
            dependencies: ["ConfidentialUtils"]
        ),

        // Utils
        .target(name: "ConfidentialUtils"),

        // Tests
        .testTarget(
            name: "ConfidentialKitTests",
            dependencies: ["ConfidentialKit"]
        ),
        .testTarget(
            name: "ConfidentialUtilsTests",
            dependencies: ["ConfidentialUtils"]
        )
    ],
    swiftLanguageVersions: [.v5]
)

#if os(macOS)
package.products.append(
    .library(
        name: "ConfidentialObfuscator",
        targets: ["ConfidentialObfuscator"]
    )
)
package.dependencies.append(contentsOf: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
    .package(url: "https://github.com/swiftlang/swift-syntax.git", "509.1.1"..<"602.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.14.1"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "5.4.0")
])
package.targets.append(contentsOf: [
    // Core Module
    .target(
        name: "ConfidentialCore",
        dependencies: [
            "ConfidentialKit",
            "ConfidentialUtils",
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            .product(name: "Parsing", package: "swift-parsing")
        ]
    ),

    // Obfuscator
    .target(
        name: "ConfidentialObfuscator",
        dependencies: [
            "ConfidentialCore",
            .product(name: "Yams", package: "Yams"),
            .product(name: "Parsing", package: "swift-parsing")
        ]
    ),

    // CLI Tool
    .executableTarget(
        name: "swift-confidential",
        dependencies: [
            "ConfidentialObfuscator",
            .product(name: "ArgumentParser", package: "swift-argument-parser")
        ]
    ),

    // Tests
    .testTarget(
        name: "ConfidentialCoreTests",
        dependencies: ["ConfidentialCore"]
    ),
    .testTarget(
        name: "ConfidentialObfuscatorTests",
        dependencies: ["ConfidentialObfuscator"]
    )
])
#endif
