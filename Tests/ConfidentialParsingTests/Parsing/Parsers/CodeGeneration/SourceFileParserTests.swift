@testable import ConfidentialParsing
import XCTest

import SwiftSyntax

final class SourceFileParserTests: XCTestCase {

    private typealias CodeBlockParserSpy = ParserSpy<SourceFileSpec, [CodeBlockItemSyntax]>

    private typealias SUT = SourceFileParser<CodeBlockParserSpy>

    private let enumNameStub = "Secrets"

    private var codeBlockParserSpy: CodeBlockParserSpy!

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        codeBlockParserSpy = .init(result: codeBlockStub)
        codeBlockParserSpy.consumeInput = { $0.secrets = [:] }
        sut = .init {
            codeBlockParserSpy!
        }
    }

    override func tearDown() {
        sut = nil
        codeBlockParserSpy = nil
        super.tearDown()
    }

    func test_givenSourceFileSpec_whenParse_thenReturnsExpectedSourceFileTextAndInputIsConsumed() throws {
        // given
        var sourceFileSpec = SourceFileSpec.StubFactory.makeSpec(
            secrets: [
                .create(identifier: enumNameStub): []
            ]
        )

        // when
        let sourceFileText: SourceFileText = try sut.parse(&sourceFileSpec)

        // then
        XCTAssertEqual(
            """

            enum \(enumNameStub) {
            }
            """,
            .init(describing: sourceFileText)
        )
        XCTAssertTrue(sourceFileSpec.secrets.isEmpty)
    }

    func test_givenCodeBlockParserFails_whenParse_thenThrowsError() {
        // given
        var sourceFileSpec = SourceFileSpec.StubFactory.makeSpec()
        codeBlockParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&sourceFileSpec))
    }
}

private extension SourceFileParserTests {

    var codeBlockStub: [CodeBlockItemSyntax] {
        [
            .init(
                leadingTrivia: .newline,
                item: .init(
                    EnumDeclSyntax(
                        name: .identifier(enumNameStub),
                        memberBlock: MemberBlockSyntax(
                            leftBrace: .leftBraceToken(leadingTrivia: .spaces(1)),
                            members: []
                        )
                    )
                )
            )
        ]
    }
}
