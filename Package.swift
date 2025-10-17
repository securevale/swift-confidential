// swift-tools-version: 6.0

import CompilerPluginSupport
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
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.1"..<"603.0.0")
    ],
    targets: [
        // Core Module
        .target(
            name: "ConfidentialCore",
            dependencies: [
                "ConfidentialUtils"
            ]
        ),

        // Client Library
        .target(
            name: "ConfidentialKit",
            dependencies: [
                "ConfidentialCore",
                "ConfidentialKitMacros"
            ]
        ),

        // Macros
        .macro(
            name: "ConfidentialKitMacros",
            dependencies: [
                "ConfidentialCore",
                "ConfidentialUtils",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Utils
        .target(name: "ConfidentialUtils"),

        // Tests
        .testTarget(
            name: "ConfidentialCoreTests",
            dependencies: ["ConfidentialCore"]
        ),
        .testTarget(
            name: "ConfidentialKitMacrosTests",
            dependencies: [
                "ConfidentialCore",
                "ConfidentialKitMacros",
                "ConfidentialUtils",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "ConfidentialUtilsTests",
            dependencies: ["ConfidentialUtils"]
        )
    ],
    swiftLanguageModes: [.v5, .v6]
)

#if os(macOS)
package.dependencies.append(contentsOf: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
    .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.14.1"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "6.1.0")
])
package.targets.append(contentsOf: [
    // Parsing
    .target(
        name: "ConfidentialParsing",
        dependencies: [
            "ConfidentialCore",
            "ConfidentialUtils",
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            .product(name: "Parsing", package: "swift-parsing")
        ]
    ),

    // CLI Tool
    .executableTarget(
        name: "swift-confidential",
        dependencies: [
            "ConfidentialParsing",
            "Yams",
            .product(name: "ArgumentParser", package: "swift-argument-parser")
        ]
    ),

    // Tests
    .testTarget(
        name: "ConfidentialParsingTests",
        dependencies: ["ConfidentialParsing"]
    )
])
#endif
