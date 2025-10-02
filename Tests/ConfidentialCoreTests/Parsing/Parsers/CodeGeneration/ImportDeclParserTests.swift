@testable import ConfidentialCore
import XCTest

import SwiftSyntax

final class ImportDeclParserTests: XCTestCase {

    private typealias SUT = ImportDeclParser

    private let algorithmStub: SourceFileSpec.Algorithm = [.shuffle]
    private let customModuleNameStub = "Crypto"

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        sut = .init()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_givenInternalImportDisabled_whenParse_thenReturnsExpectedImportDeclStatementsAndInputLeftIntact() throws {
        // given
        let secrets: SourceFileSpec.Secrets = [
            .extend(identifier: "Obfuscation.Secret", moduleName: C.Code.Generation.confidentialKitModuleName): [
                .StubFactory.makeInternalSecret()
            ],
            .extend(identifier: "Pinning", moduleName: customModuleNameStub): [
                .StubFactory.makePublicSecret(named: "secret1"),
                .StubFactory.makePublicSecret(named: "secret2")
            ]
        ]
        var sourceFileSpec: SourceFileSpec = .StubFactory.makeSpec(
            algorithm: algorithmStub,
            experimentalMode: false,
            internalImport: false,
            secrets: secrets
        )

        // when
        let statements = try XCTUnwrap(sut.parse(&sourceFileSpec))

        // then
        XCTAssertEqual(
            """
            import \(C.Code.Generation.confidentialKitModuleName)
            import \(customModuleNameStub)
            import \(C.Code.Generation.foundationModuleName)
            """,
            String(describing: syntax(from: statements))
        )
        XCTAssertEqual(algorithmStub, sourceFileSpec.algorithm)
        XCTAssertFalse(sourceFileSpec.experimentalMode)
        XCTAssertFalse(sourceFileSpec.internalImport)
        XCTAssertEqual(secrets, sourceFileSpec.secrets)
    }

    func test_givenInternalImportEnabled_whenParse_thenReturnsExpectedImportDeclStatementsAndInputLeftIntact() throws {
        // given
        let secrets: SourceFileSpec.Secrets = [
            .extend(identifier: "Obfuscation.Secret", moduleName: C.Code.Generation.confidentialKitModuleName): [
                .StubFactory.makeInternalSecret()
            ],
            .extend(identifier: "Pinning", moduleName: customModuleNameStub): [
                .StubFactory.makeInternalSecret()
            ]
        ]
        var sourceFileSpec: SourceFileSpec = .StubFactory.makeSpec(
            algorithm: algorithmStub,
            experimentalMode: false,
            internalImport: true,
            secrets: secrets
        )

        // when
        let statements = try XCTUnwrap(sut.parse(&sourceFileSpec))

        // then
        XCTAssertEqual(
            """
            internal import \(C.Code.Generation.confidentialKitModuleName)
            import \(customModuleNameStub)
            import \(C.Code.Generation.foundationModuleName)
            """,
            String(describing: syntax(from: statements))
        )
        XCTAssertEqual(algorithmStub, sourceFileSpec.algorithm)
        XCTAssertFalse(sourceFileSpec.experimentalMode)
        XCTAssertTrue(sourceFileSpec.internalImport)
        XCTAssertEqual(secrets, sourceFileSpec.secrets)
    }

    func test_givenInternalImportEnabledAndNonInternalAccessLevel_whenParse_thenThrowsExpectedErrorAndInputLeftIntact() {
        // given
        let packageSecrets: SourceFileSpec.Secrets = [
            .create(identifier: "Secrets"): [
                .StubFactory.makeInternalSecret(named: "secret1")
            ],
            .extend(identifier: "Obfuscation.Secret", moduleName: "ConfidentialKit"): [
                .StubFactory.makeInternalSecret(named: "secret1"),
                .StubFactory.makePackageSecret(named: "secret2")
            ]
        ]
        let publicSecrets: SourceFileSpec.Secrets = [
            .create(identifier: "Secrets"): [
                .StubFactory.makeInternalSecret(named: "secret1"),
                .StubFactory.makePublicSecret(named: "secret2")
            ]
        ]
        let sourceFileSpecs = [packageSecrets, publicSecrets].map { secrets in
            (
                SourceFileSpec.StubFactory.makeSpec(
                    algorithm: algorithmStub,
                    experimentalMode: false,
                    internalImport: true,
                    secrets: secrets
                ),
                secrets
            )
        }

        // when & then
        for (sourceFileSpec, secrets) in sourceFileSpecs {
            var sourceFileSpec = sourceFileSpec
            XCTAssertThrowsError(try sut.parse(&sourceFileSpec)) { error in
                XCTAssertEqual(
                    """
                    Cannot use internal import when the secret(s) access \
                    level is package or public.
                    Either change the access level to internal, or disable \
                    internal import.
                    """,
                    "\(error)"
                )
            }
            XCTAssertEqual(algorithmStub, sourceFileSpec.algorithm)
            XCTAssertFalse(sourceFileSpec.experimentalMode)
            XCTAssertTrue(sourceFileSpec.internalImport)
            XCTAssertEqual(secrets, sourceFileSpec.secrets)
        }
    }
}

private extension ImportDeclParserTests {

    func syntax(from statements: [CodeBlockItemSyntax]) -> Syntax {
        CodeBlockItemListSyntax(statements)
            .formatted(using: .init(indentationWidth: .spaces(0)))
    }
}
