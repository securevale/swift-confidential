@testable import ConfidentialCore
import XCTest

final class SourceSpecificationParserTests: XCTestCase {

    private typealias AlgorithmParserSpy = ParserSpy<Configuration, SourceSpecification.Algorithm>
    private typealias SecretsParserSpy = ParserSpy<Configuration, SourceSpecification.Secrets>

    private let configurationStub: Configuration = {
        var configuration = Configuration.StubFactory.makeConfiguration()
        configuration.defaultAccessModifier = "internal"
        configuration.defaultNamespace = "Secrets"
        configuration.implementationOnlyImport = false
        return configuration
    }()
    private let algorithmStub: SourceSpecification.Algorithm = [
        .init(technique: .encryption(algorithm: .chaChaPoly))
    ]
    private let secretsStub: SourceSpecification.Secrets = [
        .extend(identifier: "Secrets", moduleName: "SecretModule"): [.StubFactory.makePublicSecret()]
    ]

    private var algorithmParserSpy: AlgorithmParserSpy!
    private var secretsParserSpy: SecretsParserSpy!

    private var sut: SourceSpecificationParser<AlgorithmParserSpy, SecretsParserSpy>!

    override func setUp() {
        super.setUp()
        algorithmParserSpy = .init(result: algorithmStub)
        algorithmParserSpy.consumeInput = { $0.algorithm = [] }
        secretsParserSpy = .init(result: secretsStub)
        secretsParserSpy.consumeInput = { $0.secrets = [] }
        sut = .init(
            algorithmParser: algorithmParserSpy,
            secretsParser: secretsParserSpy
        )
    }

    override func tearDown() {
        sut = nil
        secretsParserSpy = nil
        algorithmParserSpy = nil
        super.tearDown()
    }

    func test_givenConfiguration_whenParse_thenReturnsExpectedValueAndInputIsConsumed() throws {
        // given
        var configuration = configurationStub

        // when
        let specification: SourceSpecification = try sut.parse(&configuration)

        // then
        let expectedSpecification = SourceSpecification(
            algorithm: algorithmStub,
            importAttribute: .default,
            secrets: secretsStub
        )
        XCTAssertEqual(expectedSpecification, specification)
        XCTAssertEqual([configurationStub], algorithmParserSpy.parseRecordedInput)
        XCTAssertEqual([configurationStub], secretsParserSpy.parseRecordedInput)
        XCTAssertTrue(configuration.algorithm.isEmpty)
        XCTAssertNil(configuration.defaultAccessModifier)
        XCTAssertNil(configuration.defaultNamespace)
        XCTAssertNil(configuration.implementationOnlyImport)
        XCTAssertTrue(configuration.secrets.isEmpty)
    }

    func test_givenAlgorithmParserFails_whenParse_thenThrowsError() {
        // given
        var configuration = configurationStub
        algorithmParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&configuration))
    }

    func test_givenSecretsParserFails_whenParse_thenThrowsError() {
        // given
        var configuration = configurationStub
        secretsParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&configuration))
    }
}
