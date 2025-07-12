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
        ),
        .library(
            name: "_ConfidentialKit",
            targets: ["_ConfidentialKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "509.1.1"..<"602.0.0")
    ],
    targets: [
        // Client Library
        .target(
            name: "ConfidentialKit",
            dependencies: ["ConfidentialUtils"]
        ),
        .target(
            name: "_ConfidentialKit",
            dependencies: [
                "ConfidentialKit",
                "ConfidentialKitMacros"
            ]
        ),

        // Macros
        .macro(
            name: "ConfidentialKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Utils
        .target(name: "ConfidentialUtils"),

        // Tests
        .testTarget(
            name: "ConfidentialKitTests",
            dependencies: ["ConfidentialKit"]
        ),
        .testTarget(
            name: "ConfidentialKitMacrosTests",
            dependencies: [
                "ConfidentialKitMacros",
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

    // CLI Tool
    .executableTarget(
        name: "swift-confidential",
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
