@testable import ConfidentialCore
import XCTest

import SwiftSyntax

final class ImportDeclParserTests: XCTestCase {

    private typealias SUT = ImportDeclParser

    private let algorithmStub: SourceFileSpec.Algorithm = [.init(technique: .randomization)]
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
        var sourceFileSpecs: [SourceFileSpec] = [
            .StubFactory.makeSpec(
                algorithm: algorithmStub,
                experimentalMode: false,
                internalImport: false,
                secrets: secrets
            ),
            .StubFactory.makeSpec(
                algorithm: algorithmStub,
                experimentalMode: true,
                internalImport: false,
                secrets: secrets
            )
        ]

        // when
        let statements = try sourceFileSpecs
            .enumerated()
            .map { idx, spec in
                var spec = spec
                let statements = try XCTUnwrap(sut.parse(&spec))
                sourceFileSpecs[idx] = spec
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
        XCTAssertEqual([algorithmStub, algorithmStub], sourceFileSpecs.map(\.algorithm))
        XCTAssertEqual([false, true], sourceFileSpecs.map(\.experimentalMode))
        XCTAssertTrue(sourceFileSpecs.map(\.internalImport).allSatisfy { $0 == false })
        XCTAssertEqual([secrets, secrets], sourceFileSpecs.map(\.secrets))
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
        var sourceFileSpecs: [SourceFileSpec] = [
            .StubFactory.makeSpec(
                algorithm: algorithmStub,
                experimentalMode: false,
                internalImport: true,
                secrets: secrets
            ),
            .StubFactory.makeSpec(
                algorithm: algorithmStub,
                experimentalMode: true,
                internalImport: true,
                secrets: secrets
            )
        ]

        // when
        let statements = try sourceFileSpecs
            .enumerated()
            .map { idx, spec in
                var spec = spec
                let statements = try XCTUnwrap(sut.parse(&spec))
                sourceFileSpecs[idx] = spec
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
        XCTAssertEqual([algorithmStub, algorithmStub], sourceFileSpecs.map(\.algorithm))
        XCTAssertEqual([false, true], sourceFileSpecs.map(\.experimentalMode))
        XCTAssertTrue(sourceFileSpecs.map(\.internalImport).allSatisfy { $0 == true })
        XCTAssertEqual([secrets, secrets], sourceFileSpecs.map(\.secrets))
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
