@testable import ConfidentialCore
import XCTest

import SwiftSyntaxBuilder

final class SourceFileParserTests: XCTestCase {

    private typealias CodeBlockParserSpy = ParserSpy<SourceSpecification, [ExpressibleAsCodeBlockItem]>

    private let moduleNameStub = "SecretModule"
    private let enumNameStub = "Test"

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

    func test_givenSourceSpecification_whenParse_thenReturnsExpectedSourceFileTextAndSourceSpecificationIsEmpty() throws {
        // given
        var sourceSpecification = SourceSpecification.StubFactory.makeSpecification(
            secrets: [
                .create(identifier: "Secrets"): [],
                .extend(identifier: "Secret", moduleName: moduleNameStub): []
            ]
        )

        // when
        let sourceFileText: SourceFileText = try sut.parse(&sourceSpecification)

        // then
        XCTAssertEqual(
            """
            
            import ConfidentialKit
            import Foundation
            import \(moduleNameStub)

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
                enumKeyword: .enum.withLeadingTrivia(.newlines(1)),
                identifier: .identifier(enumNameStub),
                members: MemberDeclBlock(
                    leftBrace: .leftBrace.withLeadingTrivia(.spaces(1)),
                    members: MemberDeclList([])
                )
            )
        ]
    }
}
