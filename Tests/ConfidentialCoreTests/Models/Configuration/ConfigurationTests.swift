@testable import ConfidentialCore
import XCTest

final class ConfigurationTests: XCTestCase {

    func test_givenJSONEncodedConfiguration_whenDecodeWithJSONDecoder_thenNoThrowAndReturnsExpectedConfigurationInstance() {
        // given
        let algorithm = ["compress using lz4", "encrypt using aes-128-gcm"]
        let defaultAccessModifier = "internal"
        let defaultNamespace = "create Secrets"
        let internalImport = false
        let secret1 = ("secret1", "value", "extend Obfuscation.Secret from ConfidentialKit", "public")
        let secret2 = ("secret2", ["value1", "value2"])
        let jsonConfiguration: (String) -> Data = { internalImportLabel in
            .init(
                """
                {
                  "algorithm": [\(algorithm.map { #""\#($0)""# }.joined(separator: ","))],
                  "defaultAccessModifier": "\(defaultAccessModifier)",
                  "defaultNamespace": "\(defaultNamespace)",
                  "\(internalImportLabel)": \(internalImport),
                  "secrets": [
                    { "name": "\(secret1.0)", "value": "\(secret1.1)", "namespace": "\(secret1.2)", "accessModifier": "\(secret1.3)" },
                    { "name": "\(secret2.0)", "value": [\(secret2.1.map { #""\#($0)""# }.joined(separator: ","))] }
                  ]
                }
                """.utf8
            )
        }
        let jsonConfigurations = [
            jsonConfiguration("internalImport"),
            jsonConfiguration("implementationOnlyImport")
        ]
        let decoder = JSONDecoder()

        // when & then
        var configurations: [Configuration] = []
        XCTAssertNoThrow(
            configurations = try jsonConfigurations.map { try decoder.decode(Configuration.self, from: $0) }
        )
        let expectedConfiguration = Configuration(
            algorithm: algorithm[...],
            defaultAccessModifier: defaultAccessModifier,
            defaultNamespace: defaultNamespace,
            internalImport: internalImport,
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
        )
        XCTAssertEqual([expectedConfiguration, expectedConfiguration], configurations)
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
              "internalImport": 1,
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
}
