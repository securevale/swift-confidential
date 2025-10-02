@testable import ConfidentialCore
import XCTest

import ConfidentialKit

final class CompressStepParserTests: XCTestCase {

    private typealias Algorithm = Obfuscation.Compression.CompressionAlgorithm
    private typealias ObfuscationStep = SourceFileSpec.ObfuscationStep

    private typealias SUT = CompressStepParser

    private var sut: SUT!

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
        let steps = try inputData.indices.map {
            try sut.parse(&inputData[$0])
        }

        // then
        let expectedSteps = Algorithm.allCases.map { ObfuscationStep.compress(algorithm: $0) }
        XCTAssertEqual(inputData.count, steps.count)
        XCTAssertEqual(expectedSteps.count, steps.count)
        steps.enumerated().forEach { idx, step in
            XCTAssertEqual(expectedSteps[idx], step)
            XCTAssertTrue(inputData[idx].isEmpty)
        }
    }

    func test_givenValidInputWithExtraWhitespaces_whenParse_thenReturnsExpectedEnumValueAndInputIsEmpty() throws {
        // given
        var input = " \(C.Parsing.Keywords.compress)  \(C.Parsing.Keywords.using)   \(Algorithm.lz4.description)"[...]

        // when
        let step = try sut.parse(&input)

        // then
        XCTAssertEqual(.compress(algorithm: .lz4), step)
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
