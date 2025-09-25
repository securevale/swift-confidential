@testable import ConfidentialCore
import XCTest

import ConfidentialKit
import ConfidentialUtils

final class SecretsParserTests: XCTestCase {

    private typealias Namespace = SourceFileSpec.Secret.Namespace
    private typealias AccessModifier = SourceFileSpec.Secret.AccessModifier
    private typealias NamespaceParserSpy = ParserSpy<Substring, Namespace>
    private typealias AccessModifierSpy = ParserSpy<Substring, AccessModifier>
    private typealias Secrets = SourceFileSpec.Secrets

    private typealias SUT = SecretsParser<NamespaceParserSpy, AccessModifierSpy>

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

    private var sut: SUT!

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
        let expectedSecrets: SourceFileSpec.Secrets = [
            secretsNamespaceStub: try secretsStub.map {
                try SourceFileSpec.Secret.StubFactory.makeSecret(
                    from: $0,
                    using: secretValueEncoderSpy.underlyingEncoder,
                    nonce: nonceStub
                )
            }[...]
        ]
        XCTAssertEqual(expectedSecrets, secrets)
        typealias DataTypes = Configuration.Secret.Value.DataTypes
        let expectedDataProjectionAttributeNames = [
            TypeInfo(of: DataTypes.SingleValue.self).fullyQualifiedName,
            TypeInfo(of: DataTypes.Array.self).fullyQualifiedName
        ].map { "\(C.Code.Generation.obfuscatedMacroFullyQualifiedName)<\($0)>" }
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
        XCTAssertEqual(0, generateNonceSpy.callCount)
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
        XCTAssertEqual(0, generateNonceSpy.callCount)
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
