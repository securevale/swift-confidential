@testable import ConfidentialCore
import XCTest

import SwiftBasicFormat
import SwiftSyntax

final class NamespaceMembersParserTests: XCTestCase {

    private typealias Secret = SourceFileSpec.Secret
    private typealias SecretDeclParserSpy = ParserSpy<Secret, any DeclSyntaxProtocol>

    private typealias SUT = NamespaceMembersParser<SecretDeclParserSpy>

    private let secretDeclStub = VariableDeclSyntax.makeSecretVariableDecl(
        dataProjectionAttribute: AttributeSyntax(
            attributeName: IdentifierTypeSyntax(name: .identifier("Test"))
        ),
        accessModifier: .internal,
        name: "secret",
        dataArgumentExpression: ArrayExprSyntax {
            ArrayElementSyntax(
                expression: IntegerLiteralExprSyntax(literal: "0x20"),
                trailingComma: .commaToken()
            )
            ArrayElementSyntax(
                expression: IntegerLiteralExprSyntax(literal: "0x20")
            )
        },
        nonceArgumentExpression: IntegerLiteralExprSyntax(literal: "123456789")
    )
    private let secretsStub: ArraySlice<Secret> = [
        .StubFactory.makeInternalSecret(),
        .StubFactory.makeInternalSecret()
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
        let format: BasicFormat = .init(indentationWidth: .spaces(0))
        let membersSourceText = memberDeclarations
            .map { $0.formatted(using: format) }
            .map { String(describing: $0) }
        let expectedMembersSourceText = secretsStub
            .map { _ in MemberBlockItemSyntax(leadingTrivia: .newline, decl: secretDeclStub) }
            .map { $0.formatted(using: format) }
            .map { String(describing: $0) }
        XCTAssertEqual(expectedMembersSourceText, membersSourceText)
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
        XCTAssertEqual(secretsStub, secretDeclParserSpy.parseRecordedInput[...])
        XCTAssertEqual(secretsStub.dropFirst(), secrets)
    }
}
