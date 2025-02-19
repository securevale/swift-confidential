@testable import ConfidentialCore
import XCTest

import SwiftSyntax

final class ImportDeclParserTests: XCTestCase {

    private typealias SUT = ImportDeclParser

    private let algorithmStub: SourceSpecification.Algorithm = [.init(technique: .randomization)]
    private let customModuleNameStub = "Crypto"

    func test_givenInternalImportDisabled_whenParse_thenReturnsExpectedImportDeclStatementsAndInputLeftIntact() throws {
        // given
        let secrets: SourceSpecification.Secrets = [
            .extend(identifier: "Obfuscation.Secret", moduleName: C.Code.Generation.confidentialKitModuleName): [
                .StubFactory.makeInternalSecret()
            ],
            .extend(identifier: "Pinning", moduleName: customModuleNameStub): [
                .StubFactory.makePublicSecret(named: "secret1"),
                .StubFactory.makePublicSecret(named: "secret2")
            ]
        ]
        var sourceSpecifications: [SourceSpecification] = [
            .StubFactory.makeSpecification(
                algorithm: algorithmStub,
                experimentalMode: false,
                internalImport: false,
                secrets: secrets
            ),
            .StubFactory.makeSpecification(
                algorithm: algorithmStub,
                experimentalMode: true,
                internalImport: false,
                secrets: secrets
            )
        ]

        // when
        let statements = try sourceSpecifications
            .enumerated()
            .map { idx, spec in
                var spec = spec
                let statements = try SUT().parse(&spec)
                sourceSpecifications[idx] = spec
                return statements
            }

        // then
        XCTAssertEqual(
            [
                """
                import \(C.Code.Generation.confidentialKitModuleName)
                import \(customModuleNameStub)
                import \(C.Code.Generation.foundationModuleName)
                """,
                """
                import \(C.Code.Generation.confidentialKitModuleName)
                import \(customModuleNameStub)
                import \(C.Code.Generation.foundationModuleName)
                import \(C.Code.Generation.Experimental.confidentialKitModuleName)
                """
            ],
            statements.map { String(describing: syntax(from: $0)) }
        )
        XCTAssertEqual([algorithmStub, algorithmStub], sourceSpecifications.map(\.algorithm))
        XCTAssertTrue(sourceSpecifications.map(\.internalImport).allSatisfy { $0 == false })
        XCTAssertEqual([secrets, secrets], sourceSpecifications.map(\.secrets))
    }

    func test_givenInternalImportEnabled_whenParse_thenReturnsExpectedImportDeclStatementsAndInputLeftIntact() throws {
        // given
        let secrets: SourceSpecification.Secrets = [
            .extend(identifier: "Obfuscation.Secret", moduleName: C.Code.Generation.confidentialKitModuleName): [
                .StubFactory.makeInternalSecret()
            ],
            .extend(identifier: "Pinning", moduleName: customModuleNameStub): [
                .StubFactory.makeInternalSecret()
            ]
        ]
        var sourceSpecifications: [SourceSpecification] = [
            .StubFactory.makeSpecification(
                algorithm: algorithmStub,
                experimentalMode: false,
                internalImport: true,
                secrets: secrets
            ),
            .StubFactory.makeSpecification(
                algorithm: algorithmStub,
                experimentalMode: true,
                internalImport: true,
                secrets: secrets
            )
        ]

        // when
        let statements = try sourceSpecifications
            .enumerated()
            .map { idx, spec in
                var spec = spec
                let statements = try SUT().parse(&spec)
                sourceSpecifications[idx] = spec
                return statements
            }

        // then
        XCTAssertEqual(
            [
                """
                #if compiler(>=6.0) || hasFeature(AccessLevelOnImport)
                internal import \(C.Code.Generation.confidentialKitModuleName)
                #else
                @_implementationOnly import \(C.Code.Generation.confidentialKitModuleName)
                #endif
                import \(customModuleNameStub)
                import \(C.Code.Generation.foundationModuleName)
                """,
                """
                #if compiler(>=6.0) || hasFeature(AccessLevelOnImport)
                internal import \(C.Code.Generation.confidentialKitModuleName)
                internal import \(C.Code.Generation.Experimental.confidentialKitModuleName)
                #else
                @_implementationOnly import \(C.Code.Generation.confidentialKitModuleName)
                @_implementationOnly import \(C.Code.Generation.Experimental.confidentialKitModuleName)
                #endif
                import \(customModuleNameStub)
                import \(C.Code.Generation.foundationModuleName)
                """
            ],
            statements.map { String(describing: syntax(from: $0)) }
        )
        XCTAssertEqual([algorithmStub, algorithmStub], sourceSpecifications.map(\.algorithm))
        XCTAssertTrue(sourceSpecifications.map(\.internalImport).allSatisfy { $0 == true })
        XCTAssertEqual([secrets, secrets], sourceSpecifications.map(\.secrets))
    }

    func test_givenInternalImportEnabledAndPublicAccessLevel_whenParse_thenThrowsExpectedErrorAndInputLeftIntact() {
        // given
        let secrets: SourceSpecification.Secrets = [
            .create(identifier: "Secrets"): [
                .StubFactory.makeInternalSecret(named: "secret1"),
                .StubFactory.makePublicSecret(named: "secret2")
            ]
        ]
        var sourceSpecification = SourceSpecification.StubFactory.makeSpecification(
            algorithm: algorithmStub,
            internalImport: true,
            secrets: secrets
        )

        // when & then
        XCTAssertThrowsError(try SUT().parse(&sourceSpecification)) { error in
            XCTAssertEqual(
                """
                Cannot use internal import when the secret(s) access \
                level is public.
                Either change the access level to internal, or disable \
                internal import.
                """,
                "\(error)"
            )
        }
        XCTAssertEqual(algorithmStub, sourceSpecification.algorithm)
        XCTAssertTrue(sourceSpecification.internalImport)
        XCTAssertEqual(secrets, sourceSpecification.secrets)
    }
}

private extension ImportDeclParserTests {

    func syntax(from statements: [CodeBlockItemSyntax]) -> Syntax {
        CodeBlockItemListSyntax(statements)
            .formatted(using: .init(indentationWidth: .spaces(0)))
    }
}
