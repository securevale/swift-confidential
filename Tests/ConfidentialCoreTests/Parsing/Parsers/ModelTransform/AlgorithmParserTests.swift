@testable import ConfidentialCore
import XCTest

final class AlgorithmParserTests: XCTestCase {

    private typealias ObfuscationStepsParserSpy = ParserSpy<
        ArraySlice<String>, ArraySlice<SourceFileSpec.ObfuscationStep>
    >

    private typealias SUT = AlgorithmParser<ObfuscationStepsParserSpy>

    private let algorithmStub = ["step_1", "step_2"][...]

    private var algorithmGeneratorSpy: AlgorithmGeneratorSpy!
    private var obfuscationStepsParserSpy: ObfuscationStepsParserSpy!

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        algorithmGeneratorSpy = .init(generateAlgorithmReturnValue: [.shuffle])
        obfuscationStepsParserSpy = .init(result: [.compress(algorithm: .lzfse)])
        obfuscationStepsParserSpy.consumeInput = { $0 = [] }
        sut = .init(
            algorithmGenerator: algorithmGeneratorSpy,
            obfuscationStepsParser: obfuscationStepsParserSpy
        )
    }

    override func tearDown() {
        sut = nil
        obfuscationStepsParserSpy = nil
        algorithmGeneratorSpy = nil
        super.tearDown()
    }

    func test_givenConfiguration_whenParse_thenReturnsExpectedValueAndConfigurationAlgorithmIsConsumed() throws {
        // given
        var configurations: [Configuration] = [
            .StubFactory.makeConfiguration(algorithm: .none),
            .StubFactory.makeConfiguration(algorithm: .random("random")),
            .StubFactory.makeConfiguration(algorithm: .custom(algorithmStub))
        ]

        // when
        let algorithms = try configurations.indices.map {
            try sut.parse(&configurations[$0])
        }

        // then
        XCTAssertEqual(2, algorithmGeneratorSpy.generateAlgorithmCallCount)
        XCTAssertEqual(
            [
                algorithmGeneratorSpy.generateAlgorithmReturnValue,
                algorithmGeneratorSpy.generateAlgorithmReturnValue,
                obfuscationStepsParserSpy.result
            ],
            algorithms
        )
        configurations.map(\.algorithm).forEach { XCTAssertNil($0) }
    }

    func test_givenObfuscationStepsParserFailsOnFirstStep_whenParse_thenThrowsErrorAndConfigurationAlgorithmLeftIntact() {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(
            algorithm: .custom(algorithmStub)
        )
        obfuscationStepsParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&configuration))
        XCTAssertEqual([algorithmStub], obfuscationStepsParserSpy.parseRecordedInput)
        XCTAssertEqual(.custom(algorithmStub), configuration.algorithm)
    }

    func test_givenObfuscationStepsParserFailsOnSecondStep_whenParse_thenThrowsErrorAndConfigurationAlgorithmContainsAllButFirstStep() {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(
            algorithm: .custom(algorithmStub)
        )
        obfuscationStepsParserSpy.consumeInput = { input in
            input.removeFirst()
            throw ErrorDummy()
        }

        // when & then
        XCTAssertThrowsError(try sut.parse(&configuration))
        XCTAssertEqual([algorithmStub], obfuscationStepsParserSpy.parseRecordedInput)
        XCTAssertEqual(.custom(algorithmStub.dropFirst()), configuration.algorithm)
    }
}
