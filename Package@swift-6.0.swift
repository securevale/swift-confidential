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
        .tvOS(.v15)
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
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "509.1.1"..<"601.0.0")
    ],
    targets: [
        // Client Library
        .target(name: "ConfidentialKit"),
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
        )
    ],
    swiftLanguageModes: [.v5, .v6]
)

#if os(macOS)
package.dependencies.append(contentsOf: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.13.0"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6")
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
