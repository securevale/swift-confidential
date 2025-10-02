@testable import ConfidentialCore
import XCTest

import ConfidentialKit
import ConfidentialUtils
import SwiftSyntax

final class SecretVariableDeclParserTests: XCTestCase {

    private typealias SUT = SecretVariableDeclParser

    private let dataProjectionAttributeNameStub = "ConfidentialKit.Obfuscated<Swift.String>"
    private let deobfuscateArgumentNameStub = "deobfuscate"
    private let deobfuscateDataFuncNameStub = "deobfuscateData"

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        sut = .init()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_givenSecret_whenParse_thenReturnsExpectedSecretDecl() throws {
        // given
        let secrets = [
            makeSecretStub(
                accessModifier: .internal,
                attribute: makeDataProjectionAttributeStub()
            ),
            makeSecretStub(
                accessModifier: .package,
                attribute: makeDataProjectionAttributeStub()
            ),
            makeSecretStub(
                accessModifier: .public,
                attribute: makeDataProjectionAttributeStub()
            )
        ]

        // when
        let secretDecls = try secrets.map { secret in
            (secret, try XCTUnwrap(sut.parse(secret)))
        }

        // then
        let expectedDeclTypeName = TypeInfo(of: Obfuscation.Secret.self).fullyQualifiedName
        secretDecls.forEach { secret, secretDecl in
            XCTAssertEqual(
                """

                    @\(dataProjectionAttributeNameStub)(\(deobfuscateArgumentNameStub): \(deobfuscateDataFuncNameStub))
                    \(secret.accessModifier) static let \(secret.name): \(expectedDeclTypeName) = \
                .init(data: [0x20, 0x20], nonce: 123456789)
                """,
                .init(describing: syntax(from: secretDecl))
            )
        }
    }
}

private extension SecretVariableDeclParserTests {

    typealias Secret = SourceFileSpec.Secret

    func makeSecretStub(
        accessModifier: Secret.AccessModifier,
        attribute: Secret.DataProjectionAttribute
    ) -> Secret {
        .init(
            accessModifier: accessModifier,
            name: "secret",
            data: .init([0x20, 0x20]),
            nonce: 123456789,
            dataProjectionAttribute: attribute
        )
    }

    func makeDataProjectionAttributeStub() -> Secret.DataProjectionAttribute {
        .init(
            name: dataProjectionAttributeNameStub,
            arguments: [(label: deobfuscateArgumentNameStub, value: deobfuscateDataFuncNameStub)]
        )
    }
}

private extension SecretVariableDeclParserTests {

    func syntax(from secretDecl: any DeclSyntaxProtocol) -> Syntax {
        secretDecl
            .formatted(using: .init(indentationWidth: .spaces(0)))
    }
}
