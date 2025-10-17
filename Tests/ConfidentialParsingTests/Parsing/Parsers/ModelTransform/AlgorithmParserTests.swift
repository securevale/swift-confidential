@testable import ConfidentialParsing
import XCTest

import ConfidentialCore

final class AlgorithmParserTests: XCTestCase {

    private typealias ObfuscationStepsParserSpy = ParserSpy<
        ArraySlice<String>, Array<Obfuscation.Step>
    >

    private typealias SUT = AlgorithmParser<ObfuscationStepsParserSpy>

    private let algorithmStub = ["step_1", "step_2"][...]

    private var obfuscationStepsParserSpy: ObfuscationStepsParserSpy!

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        obfuscationStepsParserSpy = .init(result: [.compress(algorithm: .lzfse)])
        obfuscationStepsParserSpy.consumeInput = { $0 = [] }
        sut = .init(
            obfuscationStepsParser: obfuscationStepsParserSpy
        )
    }

    override func tearDown() {
        sut = nil
        obfuscationStepsParserSpy = nil
        super.tearDown()
    }

    func test_givenAlgorithm_whenParse_thenReturnsExpectedValueAndCustomAlgorithmIsConsumed() throws {
        // given
        var algorithms: [Configuration.Algorithm] = [
            .random("random"),
            .custom(algorithmStub)
        ]

        // when
        let outputs = try algorithms.indices.map {
            try sut.parse(&algorithms[$0])
        }

        // then
        XCTAssertEqual(
            [
                .random,
                .custom(obfuscationStepsParserSpy.result)
            ],
            outputs
        )
        XCTAssertEqual(.custom([]), algorithms[1])
    }

    func test_givenObfuscationStepsParserFailsOnFirstStep_whenParse_thenThrowsErrorAndAlgorithmLeftIntact() {
        // given
        var algorithm = Configuration.Algorithm.custom(algorithmStub)
        obfuscationStepsParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&algorithm))
        XCTAssertEqual([algorithmStub], obfuscationStepsParserSpy.parseRecordedInput)
        XCTAssertEqual(.custom(algorithmStub), algorithm)
    }

    func test_givenObfuscationStepsParserFailsOnSecondStep_whenParse_thenThrowsErrorAndAlgorithmContainsAllButFirstStep() {
        // given
        var algorithm = Configuration.Algorithm.custom(algorithmStub)
        obfuscationStepsParserSpy.consumeInput = { input in
            input.removeFirst()
            throw ErrorDummy()
        }

        // when & then
        XCTAssertThrowsError(try sut.parse(&algorithm))
        XCTAssertEqual([algorithmStub], obfuscationStepsParserSpy.parseRecordedInput)
        XCTAssertEqual(.custom(algorithmStub.dropFirst()), algorithm)
    }
}
