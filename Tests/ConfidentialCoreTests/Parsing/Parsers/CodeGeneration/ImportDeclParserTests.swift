@testable import ConfidentialCore
import XCTest

import SwiftSyntax

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
            implementationOnlyImport: false,
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
        XCTAssertFalse(sourceSpecification.implementationOnlyImport)
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
            implementationOnlyImport: true,
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
        XCTAssertTrue(sourceSpecification.implementationOnlyImport)
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
            implementationOnlyImport: true,
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
        XCTAssertTrue(sourceSpecification.implementationOnlyImport)
        XCTAssertEqual(secrets, sourceSpecification.secrets)
    }
}

private extension ImportDeclParserTests {

    func syntax(from statements: [CodeBlockItemSyntax]) -> Syntax {
        CodeBlockItemListSyntax(statements)
            .formatted(using: .init(indentationWidth: .spaces(0)))
    }
}
