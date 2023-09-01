@testable import ConfidentialCore
import XCTest

import SwiftSyntaxBuilder

final class SourceFileParserTests: XCTestCase {

    private typealias CodeBlockParserSpy = ParserSpy<SourceSpecification, [ExpressibleAsCodeBlockItem]>

    private let enumNameStub = "Secrets"

    private var codeBlockParserSpy: CodeBlockParserSpy!

    private var sut: SourceFileParser<CodeBlockParserSpy>!

    override func setUp() {
        super.setUp()
        codeBlockParserSpy = .init(result: codeBlockStub)
        codeBlockParserSpy.consumeInput = {
            $0.algorithm = []
            $0.secrets = [:]
        }
        sut = .init {
            codeBlockParserSpy!
        }
    }

    override func tearDown() {
        sut = nil
        codeBlockParserSpy = nil
        super.tearDown()
    }

    func test_givenSourceSpecification_whenParse_thenReturnsExpectedSourceFileTextAndInputIsConsumed() throws {
        // given
        var sourceSpecification = SourceSpecification.StubFactory.makeSpecification(
            secrets: [
                .create(identifier: enumNameStub): []
            ]
        )

        // when
        let sourceFileText: SourceFileText = try sut.parse(&sourceSpecification)

        // then
        XCTAssertEqual(
            """

            enum \(enumNameStub) {
            }
            """,
            .init(describing: sourceFileText)
        )
        XCTAssertTrue(sourceSpecification.algorithm.isEmpty)
        XCTAssertTrue(sourceSpecification.secrets.isEmpty)
    }

    func test_givenCodeBlockParserFails_whenParse_thenThrowsError() {
        // given
        var sourceSpecification = SourceSpecification.StubFactory.makeSpecification()
        codeBlockParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&sourceSpecification))
    }
}

private extension SourceFileParserTests {

    var codeBlockStub: [ExpressibleAsCodeBlockItem] {
        [
            EnumDecl(
                enumKeyword: .enum,
                identifier: .identifier(enumNameStub),
                members: MemberDeclBlock(
                    leftBrace: .leftBrace.withLeadingTrivia(.spaces(1)),
                    members: MemberDeclList([])
                )
            )
        ]
    }
}
