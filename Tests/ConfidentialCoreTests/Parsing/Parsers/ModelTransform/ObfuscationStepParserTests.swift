@testable import ConfidentialCore
import XCTest

import Parsing

final class ObfuscationStepParserTests: XCTestCase {

    private typealias Technique = SourceFileSpec.ObfuscationStep.Technique
    private typealias TechniqueParserSpy = ParserSpy<Substring, Technique>

    private let inputStub = "test"[...]

    private var compressionTechniqueParserSpy: TechniqueParserSpy!
    private var randomizationTechniqueParserSpy: TechniqueParserSpy!

    private var sut: ObfuscationStepParser<
        OneOfBuilder<Substring, Technique>.OneOf2<TechniqueParserSpy, TechniqueParserSpy>
    >!

    override func setUp() {
        super.setUp()
        compressionTechniqueParserSpy = .init(result: .compression(algorithm: .lz4))
        randomizationTechniqueParserSpy = .init(result: .randomization)
        sut = ObfuscationStepParser {
            compressionTechniqueParserSpy!
            randomizationTechniqueParserSpy!
        }
    }

    override func tearDown() {
        sut = nil
        randomizationTechniqueParserSpy = nil
        compressionTechniqueParserSpy = nil
        super.tearDown()
    }

    func test_givenFirstTechniqueParserSucceeds_whenParse_thenReturnsExpectedValue() throws {
        // given
        var input = inputStub
        compressionTechniqueParserSpy.consumeInput = { _ in }
        randomizationTechniqueParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when
        let obfuscationStep = try sut.parse(&input)

        // then
        XCTAssertEqual(.init(technique: compressionTechniqueParserSpy.result), obfuscationStep)
        XCTAssertEqual([inputStub], compressionTechniqueParserSpy.parseRecordedInput)
        XCTAssertEqual([], randomizationTechniqueParserSpy.parseRecordedInput)
    }

    func test_givenSecondTechniqueParserSucceeds_whenParse_thenReturnsExpectedValue() throws {
        // given
        var input = inputStub
        compressionTechniqueParserSpy.consumeInput = { _ in throw ErrorDummy() }
        randomizationTechniqueParserSpy.consumeInput = { _ in }

        // when
        let obfuscationStep = try sut.parse(&input)

        // then
        XCTAssertEqual(.init(technique: randomizationTechniqueParserSpy.result), obfuscationStep)
        XCTAssertEqual([inputStub], compressionTechniqueParserSpy.parseRecordedInput)
        XCTAssertEqual([inputStub], randomizationTechniqueParserSpy.parseRecordedInput)
    }

    func test_givenBothTechniqueParsersFail_whenParse_thenThrowsError() {
        // given
        var input = inputStub
        compressionTechniqueParserSpy.consumeInput = { _ in throw ErrorDummy() }
        randomizationTechniqueParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual([inputStub], compressionTechniqueParserSpy.parseRecordedInput)
        XCTAssertEqual([inputStub], randomizationTechniqueParserSpy.parseRecordedInput)
    }
}
