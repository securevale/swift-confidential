import ConfidentialKit
import Foundation

package struct SourceFileSpec: Equatable {
    var algorithm: Algorithm
    var experimentalMode: Bool
    var internalImport: Bool
    var secrets: Secrets
}

package extension SourceFileSpec {

    typealias Algorithm = ArraySlice<ObfuscationStep>

    struct ObfuscationStep: Equatable {
        let technique: Technique
    }

    struct Secret {
        let accessModifier: AccessModifier
        let name: String
        var data: Data
        let nonce: Obfuscation.Nonce
        let dataProjectionAttribute: DataProjectionAttribute
    }

    struct Secrets: Hashable {

        package typealias Secret = SourceFileSpec.Secret

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

package extension SourceFileSpec.ObfuscationStep {

    enum Technique: Hashable {
        case compression(algorithm: Obfuscation.Compression.CompressionAlgorithm)
        case encryption(algorithm: Obfuscation.Encryption.SymmetricEncryptionAlgorithm)
        case randomization
    }
}

extension SourceFileSpec.Secret: Hashable {

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

extension SourceFileSpec.Secret {

    enum AccessModifier: String, CaseIterable {
        case `internal`
        case `public`
    }

    struct DataProjectionAttribute {

        typealias Argument = (label: String?, value: String)

        let name: String
        let arguments: [Argument]
        let isPropertyWrapper: Bool
    }

    package enum Namespace: Hashable {
        case create(identifier: String)
        case extend(identifier: String, moduleName: String? = nil)
    }
}

extension SourceFileSpec.Secrets: Collection {

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

extension SourceFileSpec.Secrets: ExpressibleByDictionaryLiteral {

    package init(dictionaryLiteral elements: (Secret.Namespace, ArraySlice<Secret>)...) {
        self.init(.init(uniqueKeysWithValues: elements))
    }
}
