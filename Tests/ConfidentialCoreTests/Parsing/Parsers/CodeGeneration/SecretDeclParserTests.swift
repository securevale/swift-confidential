@testable import ConfidentialCore
import XCTest

import ConfidentialKit
import SwiftSyntax

final class SecretDeclParserTests: XCTestCase {

    private let deobfuscateArgumentNameStub = "deobfuscate"
    private let deobfuscateDataFuncNameStub = "deobfuscateData"

    func test_givenInternalSecret_whenParse_thenReturnsExpectedSecretDecl() throws {
        // given
        let secret = makeSecretStub(accessModifier: .internal)

        // when
        let secretDecl = try SecretDeclParser().parse(secret)

        // then
        let expectedAttributeName = secret.dataAccessWrapperInfo.typeInfo.fullyQualifiedName
        let expectedDeclTypeName = TypeInfo(of: Obfuscation.Secret.self).fullyQualifiedName
        XCTAssertEqual(
            """

                @\(expectedAttributeName)(\(deobfuscateArgumentNameStub): \(deobfuscateDataFuncNameStub))
                internal static var \(secret.name): \(expectedDeclTypeName) = .init(data: [0x20, 0x20], nonce: 123456789)
            """,
            .init(describing: syntax(from: secretDecl))
        )
    }

    func test_givenPublicSecret_whenParse_thenReturnsExpectedSecretDecl() throws {
        // given
        let secret = makeSecretStub(accessModifier: .public)

        // when
        let secretDecl = try SecretDeclParser().parse(secret)

        // then
        let expectedAttributeName = secret.dataAccessWrapperInfo.typeInfo.fullyQualifiedName
        let expectedDeclTypeName = TypeInfo(of: Obfuscation.Secret.self).fullyQualifiedName
        XCTAssertEqual(
            """

                @\(expectedAttributeName)(\(deobfuscateArgumentNameStub): \(deobfuscateDataFuncNameStub))
                public static var \(secret.name): \(expectedDeclTypeName) = .init(data: [0x20, 0x20], nonce: 123456789)
            """,
            .init(describing: syntax(from: secretDecl))
        )
    }
}

private extension SecretDeclParserTests {

    typealias Secret = SourceSpecification.Secret

    func makeSecretStub(accessModifier: Secret.AccessModifier) -> Secret {
        .init(
            accessModifier: accessModifier,
            name: "secret",
            data: .init([0x20, 0x20]),
            nonce: 123456789,
            dataAccessWrapperInfo: .init(
                typeInfo: .init(of: Obfuscated<String>.self),
                arguments: [(label: deobfuscateArgumentNameStub, value: deobfuscateDataFuncNameStub)]
            )
        )
    }
}

private extension SecretDeclParserTests {

    func syntax(from secretDecl: ExpressibleAsSecretDecl) -> Syntax {
        secretDecl
            .createSecretDecl()
            .buildSyntax(format: .init(indentWidth: .zero))
    }
}
