import ConfidentialKit

// swiftlint:disable discouraged_optional_boolean
public struct Configuration: Equatable, Decodable {
    var algorithm: ArraySlice<String>
    var defaultAccessModifier: String?
    var defaultNamespace: String?
    var implementationOnlyImport: Bool?
    var internalImport: Bool?
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
            internalImport: try container.decodeIfPresent(Bool.self, forKey: .internalImport),
            secrets: try container.decode([Secret].self, forKey: .secrets)[...]
        )
    }
}

extension Configuration {

    struct Secret: Hashable, Decodable {
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
        case internalImport
        case secrets
    }
}
