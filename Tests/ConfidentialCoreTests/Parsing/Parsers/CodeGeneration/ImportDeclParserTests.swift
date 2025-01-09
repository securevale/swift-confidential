@testable import ConfidentialCore
import XCTest

import SwiftSyntax
import SwiftSyntaxBuilder

final class ImportDeclParserTests: XCTestCase {

    private typealias SUT = ImportDeclParser

    private let algorithmStub: SourceSpecification.Algorithm = [.init(technique: .randomization)]
    private let customModuleNameStub = "Crypto"

    func test_givenImplementationOnlyImportDisabled_whenParse_thenReturnsExpectedImportDeclStatementsAndInputLeftIntact() throws {
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
        var sourceSpecification = SourceSpecification.StubFactory.makeSpecification(
            algorithm: algorithmStub,
            importAttribute: .default,
            secrets: secrets
        )

        // when
        let statements = try SUT().parse(&sourceSpecification)

        // then
        XCTAssertEqual(
            """

            import \(C.Code.Generation.confidentialKitModuleName)
            import \(customModuleNameStub)
            import \(C.Code.Generation.foundationModuleName)
            """,
            .init(describing: syntax(from: statements))
        )
        XCTAssertEqual(algorithmStub, sourceSpecification.algorithm)
        XCTAssertEqual(sourceSpecification.importAttribute, .default)
        XCTAssertEqual(secrets, sourceSpecification.secrets)
    }

    func test_givenImplementationOnlyImportEnabled_whenParse_thenReturnsExpectedImportDeclStatementsAndInputLeftIntact() throws {
        // given
        let secrets: SourceSpecification.Secrets = [
            .extend(identifier: "Obfuscation.Secret", moduleName: C.Code.Generation.confidentialKitModuleName): [
                .StubFactory.makeInternalSecret()
            ],
            .extend(identifier: "Pinning", moduleName: customModuleNameStub): [
                .StubFactory.makeInternalSecret()
            ]
        ]
        var sourceSpecification = SourceSpecification.StubFactory.makeSpecification(
            algorithm: algorithmStub,
            importAttribute: .implementationOnly,
            secrets: secrets
        )

        // when
        let statements = try SUT().parse(&sourceSpecification)

        // then
        XCTAssertEqual(
            """

            @_implementationOnly import \(C.Code.Generation.confidentialKitModuleName)
            import \(customModuleNameStub)
            import \(C.Code.Generation.foundationModuleName)
            """,
            .init(describing: syntax(from: statements))
        )
        XCTAssertEqual(algorithmStub, sourceSpecification.algorithm)
        XCTAssertEqual(sourceSpecification.importAttribute, .implementationOnly)
        XCTAssertEqual(secrets, sourceSpecification.secrets)
    }

    func test_givenImplementationOnlyImportEnabledAndPublicAccessLevel_whenParse_thenThrowsExpectedErrorAndInputLeftIntact() {
        // given
        let secrets: SourceSpecification.Secrets = [
            .create(identifier: "Secrets"): [
                .StubFactory.makeInternalSecret(named: "secret1"),
                .StubFactory.makePublicSecret(named: "secret2")
            ]
        ]
        var sourceSpecification = SourceSpecification.StubFactory.makeSpecification(
            algorithm: algorithmStub,
            importAttribute: .implementationOnly,
            secrets: secrets
        )

        // when & then
        XCTAssertThrowsError(try SUT().parse(&sourceSpecification)) { error in
            XCTAssertEqual(
                """
                Cannot use @_implementationOnly import when the secret(s) access \
                level is public.
                Either change the access level to internal, or disable \
                @_implementationOnly import.
                """,
                "\(error)"
            )
        }
        XCTAssertEqual(algorithmStub, sourceSpecification.algorithm)
        XCTAssertEqual(sourceSpecification.importAttribute, .implementationOnly)
        XCTAssertEqual(secrets, sourceSpecification.secrets)
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
        var sourceSpecification = SourceSpecification.StubFactory.makeSpecification(
            algorithm: algorithmStub,
            importAttribute: .internal,
            secrets: secrets
        )

        // when
        let statements = try SUT().parse(&sourceSpecification)

        // then
        XCTAssertEqual(
            """

            internal import \(C.Code.Generation.confidentialKitModuleName)
            import \(customModuleNameStub)
            import \(C.Code.Generation.foundationModuleName)
            """,
            .init(describing: syntax(from: statements))
        )
        XCTAssertEqual(algorithmStub, sourceSpecification.algorithm)
        XCTAssertEqual(sourceSpecification.importAttribute, .internal)
        XCTAssertEqual(secrets, sourceSpecification.secrets)
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
            importAttribute: .internal,
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
        XCTAssertEqual(sourceSpecification.importAttribute, .internal)
        XCTAssertEqual(secrets, sourceSpecification.secrets)
    }
}

private extension ImportDeclParserTests {

    func syntax(from statements: [ExpressibleAsCodeBlockItem]) -> Syntax {
        CodeBlockItemList(statements)
            .createSyntaxBuildable()
            .buildSyntax(format: .init(indentWidth: .zero), leadingTrivia: .zero)
    }
}
