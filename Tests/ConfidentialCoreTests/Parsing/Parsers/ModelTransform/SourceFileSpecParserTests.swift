@testable import ConfidentialCore
import XCTest

final class SourceFileSpecParserTests: XCTestCase {

    private typealias AlgorithmParserSpy = ParserSpy<Configuration, SourceFileSpec.Algorithm>
    private typealias SecretsParserSpy = ParserSpy<Configuration, SourceFileSpec.Secrets>

    private typealias SUT = SourceFileSpecParser<AlgorithmParserSpy, SecretsParserSpy>

    private let configurationStub: Configuration = {
        var configuration = Configuration.StubFactory.makeConfiguration()
        configuration.algorithm = nil
        configuration.defaultAccessModifier = "internal"
        configuration.defaultNamespace = "Secrets"
        configuration.experimentalMode = false
        configuration.internalImport = false
        return configuration
    }()
    private let algorithmStub: SourceFileSpec.Algorithm = [
        .encrypt(algorithm: .chaChaPoly)
    ]
    private let secretsStub: SourceFileSpec.Secrets = [
        .extend(identifier: "Secrets", moduleName: "SecretModule"): [.StubFactory.makePublicSecret()]
    ]

    private var algorithmParserSpy: AlgorithmParserSpy!
    private var secretsParserSpy: SecretsParserSpy!

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        algorithmParserSpy = .init(result: algorithmStub)
        algorithmParserSpy.consumeInput = { $0.algorithm = nil }
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
        let spec: SourceFileSpec = try sut.parse(&configuration)

        // then
        let expectedSpec = SourceFileSpec(
            algorithm: algorithmStub,
            experimentalMode: false,
            internalImport: false,
            secrets: secretsStub
        )
        XCTAssertEqual(expectedSpec, spec)
        XCTAssertEqual([configurationStub], algorithmParserSpy.parseRecordedInput)
        XCTAssertEqual([configurationStub], secretsParserSpy.parseRecordedInput)
        XCTAssertNil(configuration.algorithm)
        XCTAssertNil(configuration.defaultAccessModifier)
        XCTAssertNil(configuration.defaultNamespace)
        XCTAssertNil(configuration.experimentalMode)
        XCTAssertNil(configuration.internalImport)
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
