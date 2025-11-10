@testable import ConfidentialParsing
import XCTest

final class SecretsParserTests: XCTestCase {

    private typealias Secret = SourceFileSpec.Secret

    private typealias AccessModifierParserSpy = ParserSpy<Substring, Secret.AccessModifier>
    private typealias AlgorithmParserSpy = ParserSpy<Configuration.Algorithm, Secret.Algorithm>
    private typealias NamespaceParserSpy = ParserSpy<Substring, Secret.Namespace>

    private typealias SUT = SecretsParser<NamespaceParserSpy, AccessModifierParserSpy, AlgorithmParserSpy>

    private let configurationSecretsStub: ArraySlice<Configuration.Secret> = [
        .init(
            name: "secret1",
            value: .string("message"),
            accessModifier: .none,
            algorithm: .none,
            namespace: .none
        ),
        .init(
            name: "secret2",
            value: .stringArray(["mess", "age"]),
            accessModifier: .none,
            algorithm: .none,
            namespace: .none
        )
    ]
    private let secretsAccessModifierStub: Secret.AccessModifier = .internal
    private let secretsAlgorithmStub: Secret.Algorithm = .random
    private let secretsNamespaceStub: Secret.Namespace = .create(identifier: "Secrets")

    private var accessModifierParserSpy: AccessModifierParserSpy!
    private var algorithmParserSpy: AlgorithmParserSpy!
    private var namespaceParserSpy: NamespaceParserSpy!

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        accessModifierParserSpy = .init(result: secretsAccessModifierStub)
        accessModifierParserSpy.consumeInput = { $0 = "" }
        algorithmParserSpy = .init(result: secretsAlgorithmStub)
        namespaceParserSpy = .init(result: secretsNamespaceStub)
        namespaceParserSpy.consumeInput = { $0 = "" }
        sut = .init(
            accessModifierParser: accessModifierParserSpy,
            algorithmParser: algorithmParserSpy,
            namespaceParser: namespaceParserSpy
        )
    }

    override func tearDown() {
        sut = nil
        namespaceParserSpy = nil
        algorithmParserSpy = nil
        accessModifierParserSpy = nil
        super.tearDown()
    }

    func test_givenConfiguration_whenParse_thenReturnsExpectedValueAndConfigurationSecretsIsEmpty() throws {
        // given
        let defaultAlgorithm = Configuration.Algorithm.random("random")
        let customAlgorithm = Configuration.Algorithm.custom(["shuffle"])
        var configurationSecrets = configurationSecretsStub
        configurationSecrets[0].algorithm = customAlgorithm
        var configuration = Configuration.StubFactory.makeConfiguration(
            algorithm: defaultAlgorithm,
            secrets: configurationSecrets
        )

        // when
        let secrets = try sut.parse(&configuration)

        // then
        let expectedSecrets: SourceFileSpec.Secrets = [
            secretsNamespaceStub: configurationSecrets.map {
                SourceFileSpec.Secret(
                    accessModifier: secretsAccessModifierStub,
                    algorithm: secretsAlgorithmStub,
                    name: $0.name,
                    value: .init(from: $0.value)
                )
            }[...]
        ]
        XCTAssertEqual(expectedSecrets, secrets)
        XCTAssertEqual(
            (0..<configurationSecrets.count).map { _ in "" },
            accessModifierParserSpy.parseRecordedInput
        )
        XCTAssertEqual(
            [defaultAlgorithm, customAlgorithm],
            algorithmParserSpy.parseRecordedInput
        )
        XCTAssertEqual(
            (0..<configurationSecrets.count).map { _ in "" },
            namespaceParserSpy.parseRecordedInput
        )
        XCTAssertNil(configuration.algorithm)
        XCTAssertTrue(configuration.secrets.isEmpty)
    }

    func test_givenConfigurationWithEmptySecrets_whenParse_thenThrowsExpectedError() throws {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration()

        // when & then
        XCTAssertThrowsError(try sut.parse(&configuration)) { error in
            XCTAssertEqual("`secrets` list must not be empty.", "\(error)")
        }
    }

    func test_givenNamespaceParserFailsOnFirstSecret_whenParse_thenThrowsErrorAndConfigurationSecretsLeftIntact() {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(secrets: configurationSecretsStub)
        namespaceParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&configuration))
        XCTAssertEqual([""], namespaceParserSpy.parseRecordedInput)
        XCTAssertEqual([], accessModifierParserSpy.parseRecordedInput)
        XCTAssertEqual(configurationSecretsStub[...], configuration.secrets)
    }

    func test_givenNamespaceParserFailsOnSecondSecret_whenParse_thenThrowsErrorAndConfigurationSecretsContainsAllButFirstSecret() {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(secrets: configurationSecretsStub)
        var secretCount: Int = .zero
        namespaceParserSpy.consumeInput = { input in
            guard secretCount == .zero else {
                throw ErrorDummy()
            }
            secretCount += 1
            input = ""
        }

        // when & then
        XCTAssertThrowsError(try sut.parse(&configuration))
        XCTAssertEqual(["", ""], namespaceParserSpy.parseRecordedInput)
        XCTAssertEqual([""], accessModifierParserSpy.parseRecordedInput)
        XCTAssertEqual(configurationSecretsStub.dropFirst()[...], configuration.secrets)
    }

    func test_givenAccessModifierParserFailsOnFirstSecret_whenParse_thenThrowsErrorAndConfigurationSecretsLeftIntact() {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(secrets: configurationSecretsStub)
        accessModifierParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&configuration))
        XCTAssertEqual([""], namespaceParserSpy.parseRecordedInput)
        XCTAssertEqual([""], accessModifierParserSpy.parseRecordedInput)
        XCTAssertEqual(configurationSecretsStub[...], configuration.secrets)
    }

    func test_givenAccessModifierParserFailsOnSecondSecret_whenParse_thenThrowsErrorAndConfigurationSecretsContainsAllButFirstSecret() {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(secrets: configurationSecretsStub)
        var secretCount: Int = .zero
        accessModifierParserSpy.consumeInput = { input in
            guard secretCount == .zero else {
                throw ErrorDummy()
            }
            secretCount += 1
            input = ""
        }

        // when & then
        XCTAssertThrowsError(try sut.parse(&configuration))
        XCTAssertEqual(["", ""], namespaceParserSpy.parseRecordedInput)
        XCTAssertEqual(["", ""], accessModifierParserSpy.parseRecordedInput)
        XCTAssertEqual(configurationSecretsStub.dropFirst()[...], configuration.secrets)
    }
}
