@testable import ConfidentialParsing
import XCTest

final class SecretsParserTests: XCTestCase {

    private typealias Secret = SourceFileSpec.Secret

    private typealias NamespaceParserSpy = ParserSpy<Substring, Secret.Namespace>
    private typealias AccessModifierParserSpy = ParserSpy<Substring, Secret.AccessModifier>
    private typealias AlgorithmParserSpy = ParserSpy<Configuration.Algorithm, Secret.Algorithm>

    private typealias SUT = SecretsParser<NamespaceParserSpy, AccessModifierParserSpy, AlgorithmParserSpy>

    private let configurationSecretsStub: ArraySlice<Configuration.Secret> = [
        .init(name: "secret1", value: .string("message"), namespace: .none, accessModifier: .none),
        .init(name: "secret2", value: .stringArray(["mess", "age"]), namespace: .none, accessModifier: .none)
    ]
    private let secretsNamespaceStub: Secret.Namespace = .create(identifier: "Secrets")
    private let secretsAccessModifierStub: Secret.AccessModifier = .internal
    private let secretsAlgorithmStub: Secret.Algorithm = .random

    private var namespaceParserSpy: NamespaceParserSpy!
    private var accessModifierParserSpy: AccessModifierParserSpy!
    private var algorithmParserSpy: AlgorithmParserSpy!

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        namespaceParserSpy = .init(result: secretsNamespaceStub)
        namespaceParserSpy.consumeInput = { $0 = "" }
        accessModifierParserSpy = .init(result: secretsAccessModifierStub)
        accessModifierParserSpy.consumeInput = { $0 = "" }
        algorithmParserSpy = .init(result: secretsAlgorithmStub)
        sut = .init(
            namespaceParser: namespaceParserSpy,
            accessModifierParser: accessModifierParserSpy,
            algorithmParser: algorithmParserSpy
        )
    }

    override func tearDown() {
        sut = nil
        algorithmParserSpy = nil
        accessModifierParserSpy = nil
        namespaceParserSpy = nil
        super.tearDown()
    }

    func test_givenConfiguration_whenParse_thenReturnsExpectedValueAndConfigurationSecretsIsEmpty() throws {
        // given
        let algorithm = Configuration.Algorithm.random("random")
        var configuration = Configuration.StubFactory.makeConfiguration(
            algorithm: algorithm,
            secrets: configurationSecretsStub
        )

        // when
        let secrets = try sut.parse(&configuration)

        // then
        let expectedSecrets: SourceFileSpec.Secrets = [
            secretsNamespaceStub: configurationSecretsStub.map {
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
            (0..<configurationSecretsStub.count).map { _ in "" },
            namespaceParserSpy.parseRecordedInput
        )
        XCTAssertEqual(
            (0..<configurationSecretsStub.count).map { _ in "" },
            accessModifierParserSpy.parseRecordedInput
        )
        XCTAssertEqual([algorithm], algorithmParserSpy.parseRecordedInput)
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
