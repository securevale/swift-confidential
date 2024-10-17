import ConfidentialKit

// swiftlint:disable discouraged_optional_boolean
public struct Configuration: Equatable, Decodable {
    var algorithm: ArraySlice<String>
    var defaultAccessModifier: String?
    var defaultNamespace: String?
    var implementationOnlyImport: Bool?
    var secrets: ArraySlice<Secret>
}
// swiftlint:enable discouraged_optional_boolean

public extension Configuration {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = .init(
            algorithm: try container.decode([String].self, forKey: .algorithm)[...],
            defaultAccessModifier: try container.decodeIfPresent(String.self, forKey: .defaultAccessModifier),
            defaultNamespace: try container.decodeIfPresent(String.self, forKey: .defaultNamespace),
            implementationOnlyImport: try container.decodeIfPresent(Bool.self, forKey: .implementationOnlyImport),
            secrets: try container.decode([Secret].self, forKey: .secrets)[...]
        )
    }
}

extension Configuration {

    struct Secret: Hashable {
        let name: String
        let value: Value
        let namespace: String?
        let accessModifier: String?
    }
}

extension Configuration.Secret {

    enum Value: Hashable, Decodable {

        typealias DataTypes = Obfuscation.SupportedDataTypes

        case array(DataTypes.Array)
        case singleValue(DataTypes.SingleValue)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(DataTypes.Array.self) {
                self = .array(value)
            } else {
                let value = try container.decode(DataTypes.SingleValue.self)
                self = .singleValue(value)
            }
        }
    }
}

private extension Configuration {

    enum CodingKeys: String, CodingKey {
        case algorithm
        case defaultAccessModifier
        case defaultNamespace
        case implementationOnlyImport
        case secrets
    }
}

extension Configuration.Secret: Decodable {
    fileprivate enum CodingKeys: String, CodingKey {
        case name
        case value
        case namespace
        case accessModifier
        case environmentKey
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        namespace = try container.decodeIfPresent(String.self, forKey: .namespace)
        accessModifier = try container.decodeIfPresent(String.self, forKey: .accessModifier)
        guard container.contains(.environmentKey) else {
            value = try container.decode(Configuration.Secret.Value.self, forKey: .value)
            return
        }
        
        guard let environment = decoder.userInfo[.processInfoEnvironment] else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [CodingKeys.environmentKey],
                    debugDescription: "userInfo[CodingUserInfoKey.processInfoEnvironment] not set"
                )
            )
        }

        guard let keyedVariables = environment as? [String: String] else {
            throw DecodingError.typeMismatch([String: String].self, DecodingError.Context(codingPath: [CodingKeys.environmentKey], debugDescription: "processInfoEnvironment expected to be of [String: String] type"))
        }

        let key = try container.decode(String.self, forKey: CodingKeys.environmentKey)

        guard let environmentValue = keyedVariables[key] else {
            throw DecodingError.keyNotFound(
                CodingKeys.environmentKey,
                DecodingError.Context(
                    codingPath: [CodingKeys.environmentKey],
                    debugDescription: "environment must containn value for key `\(key)`"
                )
            )
        }

        value = .singleValue(environmentValue)
    }
}
