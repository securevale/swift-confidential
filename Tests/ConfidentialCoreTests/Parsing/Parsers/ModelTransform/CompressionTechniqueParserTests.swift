@testable import ConfidentialCore
import XCTest

import ConfidentialKit

final class CompressionTechniqueParserTests: XCTestCase {

    private typealias Algorithm = Obfuscation.Compression.CompressionAlgorithm
    private typealias Technique = CompressionTechniqueParser.Technique

    private var sut: CompressionTechniqueParser!

    override func setUp() {
        super.setUp()
        sut = .init()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_givenValidInput_whenParse_thenReturnsExpectedEnumValueAndInputIsEmpty() throws {
        // given
        var inputData = Algorithm.allCases.map { algorithm in
            "\(C.Parsing.Keywords.compress) \(C.Parsing.Keywords.using) \(algorithm.description)"[...]
        }

        // when
        let techniques = try inputData.indices.map {
            try sut.parse(&inputData[$0])
        }

        // then
        let expectedTechniques = Algorithm.allCases.map { Technique.compression(algorithm: $0) }
        XCTAssertEqual(inputData.count, techniques.count)
        XCTAssertEqual(expectedTechniques.count, techniques.count)
        techniques.enumerated().forEach { idx, technique in
            XCTAssertEqual(expectedTechniques[idx], technique)
            XCTAssertTrue(inputData[idx].isEmpty)
        }
    }

    func test_givenValidInputWithExtraWhitespaces_whenParse_thenReturnsExpectedEnumValueAndInputIsEmpty() throws {
        // given
        var input = " \(C.Parsing.Keywords.compress)  \(C.Parsing.Keywords.using)   \(Algorithm.lz4.description)"[...]

        // when
        let technique = try sut.parse(&input)

        // then
        XCTAssertEqual(.compression(algorithm: .lz4), technique)
        XCTAssertTrue(input.isEmpty)
    }

    func test_givenInvalidInput_whenParse_thenThrowsErrorAndInputLeftIntact() {
        // given
        var input = "\(C.Parsing.Keywords.shuffle)"[...]

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual("\(C.Parsing.Keywords.shuffle)", input)
    }

    func test_givenInputWithoutExpectedWhitespace_whenParse_thenThrowsErrorAndInputEqualsExpectedRemainder() {
        // given
        let inputData = [
            "\(C.Parsing.Keywords.compress)\(C.Parsing.Keywords.using) \(Algorithm.lz4.description)",
            "\(C.Parsing.Keywords.compress) \(C.Parsing.Keywords.using)\(Algorithm.lz4.description)"
        ]

        // when & then
        let expectedRemainders = [
            "\(C.Parsing.Keywords.using) \(Algorithm.lz4.description)",
            "\(Algorithm.lz4.description)"
        ]
        for idx in inputData.indices {
            var input = inputData[idx][...]
            XCTAssertThrowsError(try sut.parse(&input))
            XCTAssertEqual(expectedRemainders[idx][...], input)
        }
    }

    func test_givenInputWithVerticalWhitespace_whenParse_thenThrowsErrorAndInputEqualsExpectedRemainder() {
        // given
        let inputData = [
            """

            \(C.Parsing.Keywords.compress)
            """,
            """
            \(C.Parsing.Keywords.compress)
            \(C.Parsing.Keywords.using)
            """,
            """
            \(C.Parsing.Keywords.compress) \(C.Parsing.Keywords.using)
            \(Algorithm.lz4.description)
            """
        ]

        // when & then
        let expectedRemainders = [
            """

            \(C.Parsing.Keywords.compress)
            """,
            """

            \(C.Parsing.Keywords.using)
            """,
            """

            \(Algorithm.lz4.description)
            """
        ]
        for idx in inputData.indices {
            var input = inputData[idx][...]
            XCTAssertThrowsError(try sut.parse(&input))
            XCTAssertEqual(expectedRemainders[idx][...], input)
        }
    }

    func test_givenInputWithUnexpectedTrailingData_whenParse_thenThrowsErrorAndInputEqualsTrailingData() {
        // given
        var input = "\(C.Parsing.Keywords.compress) \(C.Parsing.Keywords.using) \(Algorithm.lz4.description) Test"[...]

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual(" Test", input)
    }
}
