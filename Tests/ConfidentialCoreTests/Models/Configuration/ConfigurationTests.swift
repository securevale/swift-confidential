@testable import ConfidentialCore
import XCTest

final class ConfigurationTests: XCTestCase {

    func test_givenJSONEncodedConfiguration_whenDecodeWithJSONDecoder_thenNoThrowAndReturnsExpectedConfigurationInstance() {
        // given
        let algorithm = ["compress using lz4", "encrypt using aes-128-gcm"]
        let defaultAccessModifier = "internal"
        let defaultNamespace = "create Secrets"
        let implementationOnlyImport = false
        let secret1 = ("secret1", "value", "extend Obfuscation.Secret from ConfidentialKit", "public")
        let secret2 = ("secret2", ["value1", "value2"])
        let jsonConfiguration = Data(
        """
        {
          "algorithm": [\(algorithm.map { #""\#($0)""# }.joined(separator: ","))],
          "defaultAccessModifier": "\(defaultAccessModifier)",
          "defaultNamespace": "\(defaultNamespace)",
          "implementationOnlyImport": \(implementationOnlyImport),
          "secrets": [
            { "name": "\(secret1.0)", "value": "\(secret1.1)", "namespace": "\(secret1.2)", "accessModifier": "\(secret1.3)" },
            { "name": "\(secret2.0)", "value": [\(secret2.1.map { #""\#($0)""# }.joined(separator: ","))] }
          ]
        }
        """.utf8
        )
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.processInfoEnvironment] = [:]

        // when & then
        var configuration: Configuration?
        XCTAssertNoThrow(
            configuration = try decoder.decode(Configuration.self, from: jsonConfiguration)
        )
        XCTAssertEqual(
            Configuration(
                algorithm: algorithm[...],
                defaultAccessModifier: defaultAccessModifier,
                defaultNamespace: defaultNamespace,
                implementationOnlyImport: implementationOnlyImport,
                secrets: [
                    .init(
                        name: secret1.0,
                        value: .singleValue(secret1.1),
                        namespace: secret1.2,
                        accessModifier: secret1.3
                    ),
                    .init(
                        name: secret2.0,
                        value: .array(secret2.1),
                        namespace: .none,
                        accessModifier: .none
                    )
                ][...]
            ),
            configuration
        )
    }

    func test_givenInvalidJSONEncodedConfiguration_whenDecodeWithJSONDecoder_thenThrowsError() {
        // given
        let invalidConfigurations = [
            """
            {
              "algorithm": ["compress using lz4"]
            }
            """,
            """
            {
              "secrets": [{ "name": "secret", "value": "value" }]
            }
            """,
            """
            {
              "algorithm": ["compress using lz4"],
              "defaultAccessModifier": [],
              "secrets": [{ "name": "secret", "value": "value" }]
            }
            """,
            """
            {
              "algorithm": ["compress using lz4"],
              "defaultNamespace": [],
              "secrets": [{ "name": "secret", "value": "value" }]
            }
            """,
            """
            {
              "algorithm": ["compress using lz4"],
              "implementationOnlyImport": 1,
              "secrets": [{ "name": "secret", "value": "value" }]
            }
            """
        ].map { ($0, $0.data(using: .utf8)!) }
        let decoder = JSONDecoder()

        // when & then
        for (json, jsonData) in invalidConfigurations {
            XCTAssertThrowsError(try decoder.decode(Configuration.self, from: jsonData), json)
        }
    }

    func test_givenSecretSingleValue_whenJSONEncodeUnderlyingValue_thenResultEqualsJSONEncodedAssociatedValue() throws {
        // given
        let associatedValue = "test"
        let value = Configuration.Secret.Value.singleValue(associatedValue)
        let encoder = JSONEncoder()

        // when
        let result = try encoder.encode(value.underlyingValue)

        // then
        XCTAssertEqual(
            try encoder.encode(associatedValue),
            result
        )
    }

    func test_givenSecretArrayValue_whenJSONEncodeUnderlyingValue_thenResultEqualsJSONEncodedAssociatedValue() throws {
        // given
        let associatedValue = ["test"]
        let value = Configuration.Secret.Value.array(associatedValue)
        let encoder = JSONEncoder()

        // when
        let result = try encoder.encode(value.underlyingValue)

        // then
        XCTAssertEqual(
            try encoder.encode(associatedValue),
            result
        )
    }

    func test_givenSecretSingleEnvironmentalValue_whenDecodeWithJSONDecoder_thenNoThrowAndReturnsExpectedValueInstance() throws {
        // given
        let environmentKey = "foo"
        let environmentValue = "bar"
        let environment = [environmentKey : environmentValue]
        let secret = ("secret", environmentKey, environmentValue)
        let jsonValue = try XCTUnwrap(
        """
        { "name": "\(secret.0)", "environmentKey": "\(secret.1)" }
        """.data(using: .utf8)
        )
        let decoder = JSONDecoder()
        decoder.userInfo[.processInfoEnvironment] = environment

        // when
        let decodedSecret = try decoder.decode(Configuration.Secret.self, from: jsonValue)

        // then
        XCTAssertEqual(
            Configuration.Secret(
                name: secret.0,
                value: .singleValue(secret.2),
                namespace: .none,
                accessModifier: .none
            ),
            decodedSecret
        )
    }

    func test_givenSecretSingleMissingEnvironmentalValue_whenDecodeWithJSONDecoder_thenThrowsError() throws {

        // given
        let environmentKey = "foo"
        XCTAssertNil(ProcessInfo.processInfo.environment[environmentKey])
        let secret = ("secret", environmentKey)
        let jsonValue = try XCTUnwrap(
        """
        { "name": "\(secret.0)", "environmentKey": "\(secret.1)" }
        """.data(using: .utf8)
        )
        let decoder = JSONDecoder()
        decoder.userInfo[.processInfoEnvironment] = [:]

        // when
        XCTAssertThrowsError(try decoder.decode(Configuration.Secret.self, from: jsonValue))
    }
}
