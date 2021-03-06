@testable import ConfidentialCore
import XCTest

final class ConfigurationTests: XCTestCase {

    func test_givenJSONEncodedConfiguration_whenDecodeWithJSONDecoder_thenNoThrowAndReturnsExpectedConfigurationInstance() {
        // given
        let algorithm = ["compress using lz4", "encrypt using aes-128-gcm"]
        let defaultNamespace = "create Secrets"
        let secret1 = ("secret1", "value", "extend Obfuscation.Secret from ConfidentialKit")
        let secret2 = ("secret2", ["value1", "value2"])
        let jsonConfiguration =
        """
        {
          "algorithm": [\(algorithm.map { #""\#($0)""# }.joined(separator: ","))],
          "defaultNamespace": "\(defaultNamespace)",
          "secrets": [
            { "name": "\(secret1.0)", "value": "\(secret1.1)", "namespace": "\(secret1.2)" },
            { "name": "\(secret2.0)", "value": [\(secret2.1.map { #""\#($0)""# }.joined(separator: ","))] }
          ]
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()

        // when & then
        var configuration: Configuration?
        XCTAssertNoThrow(
            configuration = try decoder.decode(Configuration.self, from: jsonConfiguration)
        )
        XCTAssertEqual(
            Configuration(
                algorithm: algorithm[...],
                defaultNamespace: defaultNamespace,
                secrets: [
                    .init(name: secret1.0, value: .singleValue(secret1.1), namespace: secret1.2),
                    .init(name: secret2.0, value: .array(secret2.1), namespace: .none)
                ][...]
            ),
            configuration
        )
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
