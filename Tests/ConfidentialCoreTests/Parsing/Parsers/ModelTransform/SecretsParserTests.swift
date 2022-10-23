@testable import ConfidentialCore
import XCTest

final class SecretsParserTests: XCTestCase {

    private typealias Namespace = SourceSpecification.Secret.Namespace
    private typealias AccessModifier = SourceSpecification.Secret.AccessModifier
    private typealias NamespaceParserSpy = ParserSpy<Substring, Namespace>
    private typealias AccessModifierSpy = ParserSpy<Substring, AccessModifier>
    private typealias Secrets = SourceSpecification.Secrets

    private let secretsNamespaceStub: Namespace = .create(identifier: "Secrets")
    private let secretsAccessModifierStub: AccessModifier = .internal
    private let secretsStub: ArraySlice<Configuration.Secret> = [
        .init(name: "secret1", value: .singleValue("message"), namespace: .none, accessModifier: .none),
        .init(name: "secret2", value: .array(["mess", "age"]), namespace: .none, accessModifier: .none)
    ]

    private var namespaceParserSpy: NamespaceParserSpy!
    private var accessModifierParserSpy: AccessModifierSpy!
    private var secretValueEncoderSpy: DataEncoderSpy!

    private var sut: SecretsParser<NamespaceParserSpy, AccessModifierSpy>!

    override func setUp() {
        super.setUp()
        namespaceParserSpy = .init(result: secretsNamespaceStub)
        namespaceParserSpy.consumeInput = { $0 = "" }
        accessModifierParserSpy = .init(result: secretsAccessModifierStub)
        accessModifierParserSpy.consumeInput = { $0 = "" }
        secretValueEncoderSpy = .init(underlyingEncoder: JSONEncoder())
        sut = .init(
            namespaceParser: namespaceParserSpy,
            accessModifierParser: accessModifierParserSpy,
            secretValueEncoder: secretValueEncoderSpy
        )
    }

    override func tearDown() {
        sut = nil
        secretValueEncoderSpy = nil
        accessModifierParserSpy = nil
        namespaceParserSpy = nil
        super.tearDown()
    }

    func test_givenConfiguration_whenParse_thenReturnsExpectedValueAndConfigurationSecretsIsEmpty() throws {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(secrets: secretsStub)

        // when
        let secrets: Secrets = try sut.parse(&configuration)

        // then
        let expectedSecrets: SourceSpecification.Secrets = [
            secretsNamespaceStub: try secretsStub.map {
                try SourceSpecification.Secret.StubFactory.makeSecret(
                    from: $0,
                    using: secretValueEncoderSpy.underlyingEncoder
                )
            }[...]
        ]
        XCTAssertEqual(expectedSecrets, secrets)
        XCTAssertEqual(
            ["Obfuscated<String>", "Obfuscated<Array<String>>"],
            secrets[secretsNamespaceStub]?.map { $0.dataAccessWrapperInfo.typeInfo.name }
        )
        XCTAssertEqual((0..<secretsStub.count).map { _ in "" }, namespaceParserSpy.parseRecordedInput)
        XCTAssertEqual((0..<secretsStub.count).map { _ in "" }, accessModifierParserSpy.parseRecordedInput)
        XCTAssertEqual(secretsStub.count, secretValueEncoderSpy.encodeRecordedValues.count)
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
        var configuration = Configuration.StubFactory.makeConfiguration(secrets: secretsStub)
        namespaceParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&configuration))
        XCTAssertEqual([""], namespaceParserSpy.parseRecordedInput)
        XCTAssertEqual([], accessModifierParserSpy.parseRecordedInput)
        XCTAssertEqual(secretsStub[...], configuration.secrets)
    }

    func test_givenNamespaceParserFailsOnSecondSecret_whenParse_thenThrowsErrorAndConfigurationSecretsContainsAllButFirstSecret() {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(secrets: secretsStub)
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
        XCTAssertEqual(secretsStub.dropFirst()[...], configuration.secrets)
    }

    func test_givenAccessModifierParserFailsOnFirstSecret_whenParse_thenThrowsErrorAndConfigurationSecretsLeftIntact() {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(secrets: secretsStub)
        accessModifierParserSpy.consumeInput = { _ in throw ErrorDummy() }

        // when & then
        XCTAssertThrowsError(try sut.parse(&configuration))
        XCTAssertEqual([""], namespaceParserSpy.parseRecordedInput)
        XCTAssertEqual([""], accessModifierParserSpy.parseRecordedInput)
        XCTAssertEqual(secretsStub[...], configuration.secrets)
    }

    func test_givenAccessModifierParserFailsOnSecondSecret_whenParse_thenThrowsErrorAndConfigurationSecretsContainsAllButFirstSecret() {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(secrets: secretsStub)
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
        XCTAssertEqual(secretsStub.dropFirst()[...], configuration.secrets)
    }
}
