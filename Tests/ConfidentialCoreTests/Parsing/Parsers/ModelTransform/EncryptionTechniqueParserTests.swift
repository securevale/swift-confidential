@testable import ConfidentialCore
import XCTest

import ConfidentialKit

final class EncryptionTechniqueParserTests: XCTestCase {

    private typealias Algorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm
    private typealias Technique = EncryptionTechniqueParser.Technique

    private typealias SUT = EncryptionTechniqueParser

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
        let techniques = try inputData.indices.map {
            try sut.parse(&inputData[$0])
        }

        // then
        let expectedTechniques = Algorithm.allCases.map { Technique.encryption(algorithm: $0) }
        XCTAssertEqual(inputData.count, techniques.count)
        XCTAssertEqual(expectedTechniques.count, techniques.count)
        techniques.enumerated().forEach { idx, technique in
            XCTAssertEqual(expectedTechniques[idx], technique)
            XCTAssertTrue(inputData[idx].isEmpty)
        }
    }

    func test_givenValidInputWithExtraWhitespaces_whenParse_thenReturnsExpectedEnumValueAndInputIsEmpty() throws {
        // given
        var input = " \(C.Parsing.Keywords.encrypt)  \(C.Parsing.Keywords.using)   \(Algorithm.aes128GCM.description)"[...]

        // when
        let technique = try sut.parse(&input)

        // then
        XCTAssertEqual(.encryption(algorithm: .aes128GCM), technique)
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
