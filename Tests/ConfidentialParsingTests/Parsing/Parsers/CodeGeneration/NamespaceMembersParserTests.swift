@testable import ConfidentialParsing
import XCTest

import SwiftBasicFormat
import SwiftSyntax

final class NamespaceMembersParserTests: XCTestCase {

    private typealias Secret = SourceFileSpec.Secret
    private typealias SecretDeclParserSpy = ParserSpy<Secret, VariableDeclSyntax>

    private typealias SUT = NamespaceMembersParser<SecretDeclParserSpy>

    private let secretDeclStub = VariableDeclSyntax(
        .let,
        name: PatternSyntax(IdentifierPatternSyntax(identifier: .identifier("secret"))),
        initializer: InitializerClauseSyntax(
            value: StringLiteralExprSyntax(content: "test")
        )
    )
    private let secretsStub: ArraySlice<Secret> = [
        .StubFactory.makePackageSecret(algorithm: .random),
        .StubFactory.makeInternalSecret(
            algorithm: .custom(
                [
                    .compress(algorithm: .lz4),
                    .shuffle
                ]
            )
        ),
        .StubFactory.makeInternalSecret(algorithm: .random),
        .StubFactory.makeInternalSecret(algorithm: .random),
        .StubFactory.makePublicSecret(
            algorithm: .custom(
                [
                    .encrypt(algorithm: .aes128GCM)
                ]
            )
        )
    ]

    private var secretDeclParserSpy: SecretDeclParserSpy!

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        secretDeclParserSpy = .init(result: secretDeclStub)
        sut = .init(secretDeclParser: secretDeclParserSpy)
    }

    override func tearDown() {
        sut = nil
        secretDeclParserSpy = nil
        super.tearDown()
    }

    func test_givenSecrets_whenParse_thenReturnsExpectedMemberDeclarationsAndSecretsIsEmpty() throws {
        // given
        var secrets = secretsStub

        // when
        let memberDeclarations: [MemberBlockItemSyntax] = try sut.parse(&secrets)

        // then
        let membersSyntaxText = String(describing: syntax(from: memberDeclarations))
        let expectedMembersSyntaxText = """
            
            
            public static #Obfuscate(algorithm: .custom([.encrypt(algorithm: .aes128GCM)])) {
            \(String(describing: syntax(from: secretDeclStub)))
            }
            
            package static #Obfuscate(algorithm: .random) {
            \(String(describing: syntax(from: secretDeclStub)))
            }
            
            internal static #Obfuscate(algorithm: .random) {
            \(String(describing: syntax(from: secretDeclStub)))
            \(String(describing: syntax(from: secretDeclStub)))
            }
            
            internal static #Obfuscate(algorithm: .custom([.compress(algorithm: .lz4), .shuffle])) {
            \(String(describing: syntax(from: secretDeclStub)))
            }
            """
        XCTAssertEqual(expectedMembersSyntaxText, membersSyntaxText)
        XCTAssertEqual(secretsStub, secretDeclParserSpy.parseRecordedInput[...])
        XCTAssertTrue(secrets.isEmpty)
    }

    func test_givenSecretDeclParserFailsOnFirstSecret_whenParse_thenThrowsErrorAndSecretsLeftIntact() {
        // given
        var secrets = secretsStub
        secretDeclParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&secrets))
        XCTAssertEqual([secretsStub.first!], secretDeclParserSpy.parseRecordedInput)
        XCTAssertEqual(secretsStub, secrets)
    }

    func test_givenSecretDeclParserFailsOnSecondSecret_whenParse_thenThrowsErrorAndSecretsContainsAllButFirstSecret() {
        // given
        var secrets = secretsStub
        var secretCount: Int = .zero
        secretDeclParserSpy.consumeInput = { _ in
            guard secretCount == .zero else {
                throw ErrorDummy()
            }
            secretCount += 1
        }

        // when & then
        XCTAssertThrowsError(try sut.parse(&secrets))
        XCTAssertEqual(secretsStub.prefix(2), secretDeclParserSpy.parseRecordedInput[...])
        XCTAssertEqual(secretsStub.dropFirst(), secrets)
    }
}

private extension NamespaceMembersParserTests {

    func syntax(from items: [MemberBlockItemSyntax]) -> Syntax {
        MemberBlockItemListSyntax(items)
            .formatted(using: .init(indentationWidth: .spaces(0)))
    }

    func syntax(from declaration: some DeclSyntaxProtocol) -> Syntax {
        syntax(from: [MemberBlockItemSyntax(decl: declaration)])
    }
}
