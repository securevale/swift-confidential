@testable import ConfidentialCore
import XCTest

import SwiftSyntaxBuilder

final class NamespaceMembersParserTests: XCTestCase {

    private typealias Secret = SourceSpecification.Secret
    private typealias SecretDeclParserSpy = ParserSpy<Secret, ExpressibleAsSecretDecl>

    private let secretDeclStub = SecretDecl(
        name: "secret",
        dataArgumentExpression: ArrayExpr {
            ArrayElement(expression: IntegerLiteralExpr(digits: "0x20"), trailingComma: .comma)
            ArrayElement(expression: IntegerLiteralExpr(digits: "0x20"))
        },
        dataAccessWrapper: CustomAttribute(
            attributeName: SimpleTypeIdentifier("Test"),
            argumentList: .none
        )
    )
    private let secretsStub: ArraySlice<Secret> = [
        .StubFactory.makeSecret(),
        .StubFactory.makeSecret()
    ]

    private var secretDeclParserSpy: SecretDeclParserSpy!

    private var sut: NamespaceMembersParser<SecretDeclParserSpy>!

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
        let memberDeclarations: [ExpressibleAsMemberDeclListItem] = try sut.parse(&secrets)

        // then
        let format = Format(indentWidth: .zero)
        let membersSourceText = memberDeclarations
            .map { $0.createMemberDeclListItem() }
            .map { $0.buildSyntax(format: format) }
            .map { String(describing: $0) }
        let expectedMembersSourceText = secretsStub
            .map { _ in secretDeclStub.buildSyntax(format: format) }
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

    func test_givenSecretDeclParserFailsOnSecondSecret_whenParse_thenThrowsErrorAndSecretsContainAll() {
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
