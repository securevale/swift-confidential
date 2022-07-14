@testable import ConfidentialCore
import XCTest

import ConfidentialKit

final class SecretDeclParserTests: XCTestCase {

    private typealias Secret = SourceSpecification.Secret

    func test_givenSecret_whenParse_thenReturnsExpectedSecretDecl() throws {
        // given
        let deobfuscateArgumentName = "deobfuscate"
        let deobfuscateDataFuncName = "deobfuscateData"
        let secret = Secret(
            name: "secret",
            data: .init([0x20, 0x20]),
            dataAccessWrapperInfo: .init(
                typeInfo: .init(of: Obfuscated<String>.self),
                arguments: [(label: deobfuscateArgumentName, value: deobfuscateDataFuncName)]
            )
        )

        // when
        let secretDecl = try SecretDeclParser().parse(secret)

        // then
        let secretDeclSyntax = secretDecl
            .createSecretDecl()
            .buildSyntax(format: .init(indentWidth: .zero))
        let expectedAttributeName = secret.dataAccessWrapperInfo.typeInfo.fullyQualifiedName
        let expectedDeclTypeName = TypeInfo(of: Obfuscation.Secret.self).fullyQualifiedName
        XCTAssertEqual(
            """

                @\(expectedAttributeName)(\(deobfuscateArgumentName): \(deobfuscateDataFuncName))
                static var \(secret.name): \(expectedDeclTypeName) = .init(data: [0x20, 0x20])
            """,
            .init(describing: secretDeclSyntax)
        )
    }
}
