@testable import ConfidentialCore
import XCTest

import ConfidentialKit
import ConfidentialUtils
import SwiftSyntax

final class SecretVariableDeclParserTests: XCTestCase {

    private let dataProjectionAttributeNameStub = "ConfidentialKit.Obfuscated<Swift.String>"
    private let deobfuscateArgumentNameStub = "deobfuscate"
    private let deobfuscateDataFuncNameStub = "deobfuscateData"

    func test_givenInternalSecretWithPropertyWrapperAttribute_whenParse_thenReturnsExpectedSecretDecl() throws {
        // given
        let secret = makeSecretStub(
            accessModifier: .internal,
            attribute: dataProjectionAttribute(isPropertyWrapper: true)
        )

        // when
        let secretDecl = try SecretVariableDeclParser().parse(secret)

        // then
        let expectedDeclTypeName = TypeInfo(of: Obfuscation.Secret.self).fullyQualifiedName
        XCTAssertEqual(
            """

                @\(dataProjectionAttributeNameStub)(\(deobfuscateArgumentNameStub): \(deobfuscateDataFuncNameStub))
                internal static var \(secret.name): \(expectedDeclTypeName) = .init(data: [0x20, 0x20], nonce: 123456789)
            """,
            .init(describing: syntax(from: secretDecl))
        )
    }

    func test_givenPublicSecretWithMacroAttribute_whenParse_thenReturnsExpectedSecretDecl() throws {
        // given
        let secret = makeSecretStub(
            accessModifier: .public,
            attribute: dataProjectionAttribute(isPropertyWrapper: false)
        )

        // when
        let secretDecl = try SecretVariableDeclParser().parse(secret)

        // then
        let expectedDeclTypeName = TypeInfo(of: Obfuscation.Secret.self).fullyQualifiedName
        XCTAssertEqual(
            """

                @\(dataProjectionAttributeNameStub)(\(deobfuscateArgumentNameStub): \(deobfuscateDataFuncNameStub))
                public static let \(secret.name): \(expectedDeclTypeName) = .init(data: [0x20, 0x20], nonce: 123456789)
            """,
            .init(describing: syntax(from: secretDecl))
        )
    }
}

private extension SecretVariableDeclParserTests {

    typealias Secret = SourceSpecification.Secret

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

    func dataProjectionAttribute(isPropertyWrapper: Bool) -> Secret.DataProjectionAttribute {
        .init(
            name: dataProjectionAttributeNameStub,
            arguments: [(label: deobfuscateArgumentNameStub, value: deobfuscateDataFuncNameStub)],
            isPropertyWrapper: isPropertyWrapper
        )
    }
}

private extension SecretVariableDeclParserTests {

    func syntax(from secretDecl: any DeclSyntaxProtocol) -> Syntax {
        secretDecl
            .formatted(using: .init(indentationWidth: .spaces(0)))
    }
}
