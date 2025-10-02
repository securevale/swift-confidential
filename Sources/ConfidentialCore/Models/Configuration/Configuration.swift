import ConfidentialKit

// swiftlint:disable discouraged_optional_boolean
package struct Configuration: Equatable, Decodable {
    var algorithm: Algorithm?
    var defaultAccessModifier: String?
    var defaultNamespace: String?
    var experimentalMode: Bool?
    var internalImport: Bool?
    var secrets: ArraySlice<Secret>
}
// swiftlint:enable discouraged_optional_boolean

package extension Configuration {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let internalImport = if container.contains(.internalImport) {
            try container.decode(Bool.self, forKey: .internalImport)
        } else {
            // For backward compatibility:
            try container.decodeIfPresent(Bool.self, forKey: .implementationOnlyImport)
        }
        self = .init(
            algorithm: try container.decodeIfPresent(Algorithm.self, forKey: .algorithm),
            defaultAccessModifier: try container.decodeIfPresent(String.self, forKey: .defaultAccessModifier),
            defaultNamespace: try container.decodeIfPresent(String.self, forKey: .defaultNamespace),
            experimentalMode: try container.decodeIfPresent(Bool.self, forKey: .experimentalMode),
            internalImport: internalImport,
            secrets: try container.decode([Secret].self, forKey: .secrets)[...]
        )
    }
}

extension Configuration {

    var isExperimentalModeEnabled: Bool { experimentalMode ?? false }
    var isInternalImportEnabled: Bool { internalImport ?? false }
}

extension Configuration {

    enum Algorithm: Equatable, Decodable {

        case random(String)
        case custom(ArraySlice<String>)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                let algorithm = try container.decode(String.self)
                self = .random(algorithm)
            } catch DecodingError.typeMismatch {
                let algorithm = try container.decode([String].self)[...]
                self = .custom(algorithm)
            }
        }
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
            do {
                let value = try container.decode(DataTypes.SingleValue.self)
                self = .singleValue(value)
            } catch DecodingError.typeMismatch {
                let value = try container.decode(DataTypes.Array.self)
                self = .array(value)
            }
        }
    }
}

private extension Configuration {

    enum CodingKeys: String, CodingKey {
        case algorithm
        case defaultAccessModifier
        case defaultNamespace
        case experimentalMode
        case implementationOnlyImport
        case internalImport
        case secrets
    }
}
