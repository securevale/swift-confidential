@testable import ConfidentialCore
import XCTest

import Parsing

final class ObfuscationStepsParserTests: XCTestCase {

    private typealias ObfuscationStep = SourceFileSpec.ObfuscationStep
    private typealias ObfuscationStepParserSpy = ParserSpy<Substring, ObfuscationStep>

    private typealias SUT = ObfuscationStepsParser<
        OneOfBuilder<Substring, ObfuscationStep>.OneOf2<ObfuscationStepParserSpy, ObfuscationStepParserSpy>
    >

    private let inputStub = ["test"][...]

    private var compressStepParserSpy: ObfuscationStepParserSpy!
    private var shuffleStepParserSpy: ObfuscationStepParserSpy!

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        compressStepParserSpy = .init(result: .compress(algorithm: .lz4))
        shuffleStepParserSpy = .init(result: .shuffle)
        sut = ObfuscationStepsParser {
            compressStepParserSpy
            shuffleStepParserSpy
        }
    }

    override func tearDown() {
        sut = nil
        shuffleStepParserSpy = nil
        compressStepParserSpy = nil
        super.tearDown()
    }

    func test_givenFirstObfuscationStepParserSucceeds_whenParse_thenReturnsExpectedValue() throws {
        // given
        var input = inputStub
        compressStepParserSpy.consumeInput = { $0 = "" }
        shuffleStepParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when
        let obfuscationSteps = try sut.parse(&input)

        // then
        XCTAssertEqual([compressStepParserSpy.result], obfuscationSteps)
        XCTAssertEqual(inputStub.map { $0[...] }, compressStepParserSpy.parseRecordedInput)
        XCTAssertEqual([], shuffleStepParserSpy.parseRecordedInput)
    }

    func test_givenSecondObfuscationStepParserSucceeds_whenParse_thenReturnsExpectedValue() throws {
        // given
        var input = inputStub
        compressStepParserSpy.consumeInput = { _ in throw ErrorDummy() }
        shuffleStepParserSpy.consumeInput = { $0 = "" }

        // when
        let obfuscationSteps = try sut.parse(&input)

        // then
        XCTAssertEqual([shuffleStepParserSpy.result], obfuscationSteps)
        XCTAssertEqual(inputStub.map { $0[...] }, compressStepParserSpy.parseRecordedInput)
        XCTAssertEqual(inputStub.map { $0[...] }, shuffleStepParserSpy.parseRecordedInput)
    }

    func test_givenBothObfuscationStepParsersFail_whenParse_thenThrowsError() {
        // given
        var input = inputStub
        compressStepParserSpy.consumeInput = { _ in throw ErrorDummy() }
        shuffleStepParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual(inputStub.map { $0[...] }, compressStepParserSpy.parseRecordedInput)
        XCTAssertEqual(inputStub.map { $0[...] }, shuffleStepParserSpy.parseRecordedInput)
    }
}
