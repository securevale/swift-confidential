@testable import ConfidentialParsing
import XCTest

import ConfidentialCore

final class EncryptStepParserTests: XCTestCase {

    private typealias Algorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm

    private typealias SUT = EncryptStepParser

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
            "\(C.Parsing.Keywords.encrypt) \(C.Parsing.Keywords.using) \(algorithm.description)"[...]
        }

        // when
        let steps = try inputData.indices.map {
            try sut.parse(&inputData[$0])
        }

        // then
        let expectedSteps = Algorithm.allCases.map { Obfuscation.Step.encrypt(algorithm: $0) }
        XCTAssertEqual(inputData.count, steps.count)
        XCTAssertEqual(expectedSteps.count, steps.count)
        steps.enumerated().forEach { idx, step in
            XCTAssertEqual(expectedSteps[idx], step)
            XCTAssertTrue(inputData[idx].isEmpty)
        }
    }

    func test_givenValidInputWithExtraWhitespaces_whenParse_thenReturnsExpectedEnumValueAndInputIsEmpty() throws {
        // given
        var input = " \(C.Parsing.Keywords.encrypt)  \(C.Parsing.Keywords.using)   \(Algorithm.aes128GCM.description)"[...]

        // when
        let step = try sut.parse(&input)

        // then
        XCTAssertEqual(.encrypt(algorithm: .aes128GCM), step)
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
            "\(C.Parsing.Keywords.encrypt)\(C.Parsing.Keywords.using) \(Algorithm.aes128GCM.description)",
            "\(C.Parsing.Keywords.encrypt) \(C.Parsing.Keywords.using)\(Algorithm.aes128GCM.description)"
        ]

        // when & then
        let expectedRemainders = [
            "\(C.Parsing.Keywords.using) \(Algorithm.aes128GCM.description)",
            "\(Algorithm.aes128GCM.description)"
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

            \(C.Parsing.Keywords.encrypt)
            """,
            """
            \(C.Parsing.Keywords.encrypt)
            \(C.Parsing.Keywords.using)
            """,
            """
            \(C.Parsing.Keywords.encrypt) \(C.Parsing.Keywords.using)
            \(Algorithm.aes128GCM.description)
            """
        ]

        // when & then
        let expectedRemainders = [
            """

            \(C.Parsing.Keywords.encrypt)
            """,
            """

            \(C.Parsing.Keywords.using)
            """,
            """

            \(Algorithm.aes128GCM.description)
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
        var input = "\(C.Parsing.Keywords.encrypt) \(C.Parsing.Keywords.using) \(Algorithm.aes128GCM.description) Test"[...]

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual(" Test", input)
    }
}
