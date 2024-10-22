import ConfidentialKit
import Foundation

package struct SourceSpecification: Equatable {
    var algorithm: Algorithm
    var implementationOnlyImport: Bool
    var secrets: Secrets
}

package extension SourceSpecification {

    typealias Algorithm = ArraySlice<ObfuscationStep>

    struct ObfuscationStep: Equatable {
        let technique: Technique
    }

    struct Secret {
        let accessModifier: AccessModifier
        let name: String
        var data: Data
        let nonce: Obfuscation.Nonce
        let dataAccessWrapperInfo: DataAccessWrapperInfo
    }

    struct Secrets: Hashable {

        package typealias Secret = SourceSpecification.Secret

        private var secrets: [Secret.Namespace: ArraySlice<Secret>]

        var namespaces: Dictionary<Secret.Namespace, ArraySlice<Secret>>.Keys {
            secrets.keys
        }

        init(_ secrets: [Secret.Namespace: ArraySlice<Secret>]) {
            self.secrets = secrets
        }

        subscript(namespace: Secret.Namespace) -> ArraySlice<Secret>? {
            _read { yield self.secrets[namespace] }
            _modify { yield &self.secrets[namespace] }
        }
    }
}

package extension SourceSpecification.ObfuscationStep {

    enum Technique: Hashable {
        case compression(algorithm: Obfuscation.Compression.CompressionAlgorithm)
        case encryption(algorithm: Obfuscation.Encryption.SymmetricEncryptionAlgorithm)
        case randomization
    }
}

extension SourceSpecification.Secret: Hashable {

    package static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.accessModifier == rhs.accessModifier &&
        lhs.name == rhs.name &&
        lhs.data == rhs.data &&
        lhs.nonce == rhs.nonce
    }

    package func hash(into hasher: inout Hasher) {
        hasher.combine(accessModifier)
        hasher.combine(name)
        hasher.combine(data)
        hasher.combine(nonce)
    }
}

extension SourceSpecification.Secret {

    enum AccessModifier: String, CaseIterable {
        case `internal`
        case `public`
    }

    struct DataAccessWrapperInfo {

        typealias Argument = (label: String?, value: String)

        let typeInfo: TypeInfo
        let arguments: [Argument]
    }

    package enum Namespace: Hashable {
        case create(identifier: String)
        case extend(identifier: String, moduleName: String? = nil)
    }
}

extension SourceSpecification.Secrets: Collection {

    package typealias Element = Dictionary<Secret.Namespace, ArraySlice<Secret>>.Element
    package typealias Index = Dictionary<Secret.Namespace, ArraySlice<Secret>>.Index

    package var startIndex: Index {
        secrets.startIndex
    }

    package var endIndex: Index {
        secrets.endIndex
    }

    package subscript(position: Index) -> Element {
        secrets[position]
    }

    package func index(after index: Index) -> Index {
        secrets.index(after: index)
    }
}

extension SourceSpecification.Secrets: ExpressibleByDictionaryLiteral {

    package init(dictionaryLiteral elements: (Secret.Namespace, ArraySlice<Secret>)...) {
        self.init(.init(uniqueKeysWithValues: elements))
    }
}
