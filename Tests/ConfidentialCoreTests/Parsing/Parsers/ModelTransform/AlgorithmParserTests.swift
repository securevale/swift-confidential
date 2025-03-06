@testable import ConfidentialCore
import XCTest

final class AlgorithmParserTests: XCTestCase {

    private typealias ObfuscationStepParserSpy = ParserSpy<Substring, SourceFileSpec.ObfuscationStep>

    private let obfuscationStepStub = "test"
    private lazy var algorithmStub = (0..<2).map { _ in obfuscationStepStub }[...]

    private var obfuscationStepParserSpy: ObfuscationStepParserSpy!

    private var sut: AlgorithmParser<ObfuscationStepParserSpy>!

    override func setUp() {
        super.setUp()
        obfuscationStepParserSpy = .init(result: .init(technique: .compression(algorithm: .lzfse)))
        obfuscationStepParserSpy.consumeInput = { $0 = "" }
        sut = .init(obfuscationStepParser: obfuscationStepParserSpy)
    }

    override func tearDown() {
        sut = nil
        obfuscationStepParserSpy = nil
        super.tearDown()
    }

    func test_givenConfiguration_whenParse_thenReturnsExpectedValueAndConfigurationAlgorithmIsEmpty() throws {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(algorithm: algorithmStub)

        // when
        let algorithm = try sut.parse(&configuration)

        // then
        XCTAssertEqual(
            (0..<algorithmStub.count).map { _ in obfuscationStepParserSpy.result }[...],
            algorithm
        )
        XCTAssertEqual(
            algorithmStub.map { $0[...] },
            obfuscationStepParserSpy.parseRecordedInput
        )
        XCTAssertTrue(configuration.algorithm.isEmpty)
    }

    func test_givenObfuscationStepParserFailsOnFirstStep_whenParse_thenThrowsErrorAndConfigurationAlgorithmLeftIntact() {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(algorithm: algorithmStub)
        obfuscationStepParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&configuration))
        XCTAssertEqual(
            [obfuscationStepStub[...]],
            obfuscationStepParserSpy.parseRecordedInput
        )
        XCTAssertEqual(algorithmStub, configuration.algorithm)
    }

    func test_givenObfuscationStepParserFailsOnSecondStep_whenParse_thenThrowsErrorAndConfigurationAlgorithmContainsAllButFirstStep() {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(algorithm: algorithmStub)
        var stepCount: Int = .zero
        obfuscationStepParserSpy.consumeInput = { input in
            guard stepCount == .zero else {
                throw ErrorDummy()
            }
            stepCount += 1
            input = ""
        }

        // when & then
        XCTAssertThrowsError(try sut.parse(&configuration))
        XCTAssertEqual(
            algorithmStub.map { $0[...] },
            obfuscationStepParserSpy.parseRecordedInput
        )
        XCTAssertEqual(algorithmStub.dropFirst(), configuration.algorithm)
    }
}
