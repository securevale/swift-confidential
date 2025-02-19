@testable import ConfidentialCore
import XCTest

import ConfidentialKit

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
    private let nonceStub: Obfuscation.Nonce = 123456789

    private var namespaceParserSpy: NamespaceParserSpy!
    private var accessModifierParserSpy: AccessModifierSpy!
    private var secretValueEncoderSpy: DataEncoderSpy!
    private var generateNonceSpy: ParameterlessClosureSpy<UInt64>!

    private var sut: SecretsParser<NamespaceParserSpy, AccessModifierSpy>!

    override func setUp() {
        super.setUp()
        namespaceParserSpy = .init(result: secretsNamespaceStub)
        namespaceParserSpy.consumeInput = { $0 = "" }
        accessModifierParserSpy = .init(result: secretsAccessModifierStub)
        accessModifierParserSpy.consumeInput = { $0 = "" }
        secretValueEncoderSpy = .init(underlyingEncoder: JSONEncoder())
        generateNonceSpy = .init(result: nonceStub)
        sut = .init(
            namespaceParser: namespaceParserSpy,
            accessModifierParser: accessModifierParserSpy,
            secretValueEncoder: secretValueEncoderSpy,
            generateNonce: try self.generateNonceSpy.closureWithError()
        )
    }

    override func tearDown() {
        sut = nil
        generateNonceSpy = nil
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
                    using: secretValueEncoderSpy.underlyingEncoder,
                    nonce: nonceStub
                )
            }[...]
        ]
        XCTAssertEqual(expectedSecrets, secrets)
        typealias DataTypes = Configuration.Secret.Value.DataTypes
        let expectedDataProjectionAttributeNames = [
            TypeInfo(of: Obfuscated<DataTypes.SingleValue>.self).fullyQualifiedName,
            TypeInfo(of: Obfuscated<DataTypes.Array>.self).fullyQualifiedName
        ]
        XCTAssertEqual(
            expectedDataProjectionAttributeNames,
            secrets[secretsNamespaceStub]?.map { $0.dataProjectionAttribute.name }
        )
        XCTAssertEqual((0..<secretsStub.count).map { _ in "" }, namespaceParserSpy.parseRecordedInput)
        XCTAssertEqual((0..<secretsStub.count).map { _ in "" }, accessModifierParserSpy.parseRecordedInput)
        XCTAssertEqual(secretsStub.count, secretValueEncoderSpy.encodeRecordedValues.count)
        XCTAssertEqual(secretsStub.count, generateNonceSpy.callCount)
        XCTAssertTrue(configuration.secrets.isEmpty)
    }

    func test_givenConfigurationWithExperimentalModeEnabled_whenParse_thenReturnsExpectedDataProjectionAttributeNames() throws {
        // given
        var configuration = Configuration.StubFactory.makeConfiguration(
            experimentalMode: true,
            secrets: secretsStub
        )

        // when
        let secrets: Secrets = try sut.parse(&configuration)

        // then
        let expectedDataProjectionAttributeNames = [
            "\(C.Code.Generation.Experimental.obfuscatedMacroFullyQualifiedName)<Swift.String>",
            "\(C.Code.Generation.Experimental.obfuscatedMacroFullyQualifiedName)<Swift.Array<Swift.String>>"
        ]
        XCTAssertEqual(
            expectedDataProjectionAttributeNames,
            secrets[secretsNamespaceStub]?.map { $0.dataProjectionAttribute.name }
        )
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
        XCTAssertEqual(.zero, generateNonceSpy.callCount)
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
        XCTAssertEqual(1, generateNonceSpy.callCount)
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
        XCTAssertEqual(.zero, generateNonceSpy.callCount)
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
        XCTAssertEqual(1, generateNonceSpy.callCount)
        XCTAssertEqual(secretsStub.dropFirst()[...], configuration.secrets)
    }
}
