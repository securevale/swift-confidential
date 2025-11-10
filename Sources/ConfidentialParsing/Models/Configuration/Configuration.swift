// swiftlint:disable discouraged_optional_boolean
package struct Configuration: Equatable {
    var algorithm: Algorithm?
    var defaultAccessModifier: String?
    var defaultNamespace: String?
    var experimentalMode: Bool?  // <- reserved for future use
    var internalImport: Bool?
    var secrets: ArraySlice<Secret>
}
// swiftlint:enable discouraged_optional_boolean

extension Configuration: Decodable {

    package init(from decoder: Decoder) throws {
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

    enum Algorithm: Hashable, Decodable {

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
        var name: String
        var value: Value
        var accessModifier: String?
        var algorithm: Algorithm?
        var namespace: String?
    }
}

extension Configuration.Secret {

    enum Value: Hashable, Decodable {

        case string(String)
        case stringArray(Array<String>)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                let value = try container.decode(String.self)
                self = .string(value)
            } catch DecodingError.typeMismatch {
                let value = try container.decode(Array<String>.self)
                self = .stringArray(value)
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
