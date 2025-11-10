@testable import ConfidentialParsing
import XCTest

import SwiftSyntax

final class ConfidentialParserTests: XCTestCase {

    private typealias SourceFileSpecParserSpy = ParserSpy<Configuration, SourceFileSpec>
    private typealias SourceFileParserSpy = ParserSpy<SourceFileSpec, SourceFileSyntax>

    private typealias SUT = ConfidentialParser<SourceFileSpecParserSpy, SourceFileParserSpy>

    private let configurationJSONStub = Data(
        """
        {
          "secrets": [
            {
              "name": "secret",
              "value": "test"
            }
          ]
        }
        """.utf8
    )
    private let sourceFileSpecStub = SourceFileSpec.StubFactory.makeSpec()
    private let sourceFileStub: SourceFileSyntax = """
        enum Test {}
        """

    private var configurationDecoderSpy: DataDecoderSpy!
    private var sourceFileSpecParserSpy: SourceFileSpecParserSpy!
    private var sourceFileParserSpy: SourceFileParserSpy!

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        configurationDecoderSpy = .init(underlyingDecoder: JSONDecoder())
        sourceFileSpecParserSpy = .init(result: sourceFileSpecStub)
        sourceFileParserSpy = .init(result: sourceFileStub)
        sut = .init(
            configurationDecoder: configurationDecoderSpy,
            sourceFileSpecParser: sourceFileSpecParserSpy,
            sourceFileParser: sourceFileParserSpy
        )
    }

    override func tearDown() {
        sut = nil
        sourceFileParserSpy = nil
        sourceFileSpecParserSpy = nil
        configurationDecoderSpy = nil
        super.tearDown()
    }

    func test_givenJSONEncodedConfiguration_whenParse_thenReturnsExpectedSourceFileTextAndInputIsConsumed() throws {
        // given
        var input = configurationJSONStub

        // when
        let sourceFileText = try sut.parse(&input)

        // then
        XCTAssertEqual(
            SourceFileText(from: sourceFileStub),
            sourceFileText
        )
        XCTAssertTrue(input.isEmpty)
    }

    func test_givenInvalidJSONEncodedConfiguration_whenParse_thenThrowsErrorAndInputLeftIntact() {
        // given
        var input = Data("{}".utf8)
        let inputSnapshot = input

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual(inputSnapshot, input)
    }

    func test_givenSourceFileSpecParserFails_whenParse_thenThrowsError() {
        // given
        sourceFileSpecParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(configurationJSONStub))
    }

    func test_givenSourceFileParserFails_whenParse_thenThrowsError() {
        // given
        sourceFileParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(configurationJSONStub))
    }
}
