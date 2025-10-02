@testable import ConfidentialCore
import XCTest

final class ConfigurationTests: XCTestCase {

    private typealias SUT = Configuration

    func test_givenJSONEncodedConfiguration_whenDecodeWithJSONDecoder_thenNoThrowAndReturnsExpectedConfigurationInstance() {
        // given
        let defaultAccessModifier = "internal"
        let defaultNamespace = "create Secrets"
        let internalImport = false
        let secret1 = ("secret1", "value", "extend Obfuscation.Secret from ConfidentialKit", "public")
        let secret2 = ("secret2", ["value1", "value2"])
        let jsonConfiguration: (String, String) -> Data = { algorithm, internalImportLabel in
            .init(
                """
                {
                  "algorithm": \(algorithm),
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
            jsonConfiguration(#""random""#, "internalImport"),
            jsonConfiguration(#"["compress using lz4", "shuffle"]"#, "implementationOnlyImport")
        ]
        let decoder = JSONDecoder()

        print(jsonConfigurations[0])
        // when & then
        var configurations: [Configuration] = []
        XCTAssertNoThrow(
            configurations = try jsonConfigurations.map { try decoder.decode(SUT.self, from: $0) }
        )
        let expectedConfiguration: (SUT.Algorithm?) -> SUT = { algorithm in
            SUT(
                algorithm: algorithm,
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
        }
        XCTAssertEqual(
            [
                expectedConfiguration(.random("random")),
                expectedConfiguration(.custom(["compress using lz4", "shuffle"]))
            ],
            configurations
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
            XCTAssertThrowsError(try decoder.decode(SUT.self, from: jsonData), json)
        }
    }

    func test_givenSecretSingleValue_whenJSONEncodeUnderlyingValue_thenResultEqualsJSONEncodedAssociatedValue() throws {
        // given
        let associatedValue = "test"
        let value = SUT.Secret.Value.singleValue(associatedValue)
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
        let value = SUT.Secret.Value.array(associatedValue)
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
