import ConfidentialKit
import Foundation

public struct SourceSpecification: Equatable {
    var algorithm: Algorithm
    var importAttribute: ImportAttribute
    var secrets: Secrets

    public enum ImportAttribute {
        case `default`
        case implementationOnly
        case `internal`
    }
}

public extension SourceSpecification {

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

        public typealias Secret = SourceSpecification.Secret

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

public extension SourceSpecification.ObfuscationStep {

    enum Technique: Hashable {
        case compression(algorithm: Obfuscation.Compression.CompressionAlgorithm)
        case encryption(algorithm: Obfuscation.Encryption.SymmetricEncryptionAlgorithm)
        case randomization
    }
}

extension SourceSpecification.Secret: Hashable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.accessModifier == rhs.accessModifier &&
        lhs.name == rhs.name &&
        lhs.data == rhs.data &&
        lhs.nonce == rhs.nonce
    }

    public func hash(into hasher: inout Hasher) {
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

    public enum Namespace: Hashable {
        case create(identifier: String)
        case extend(identifier: String, moduleName: String? = nil)
    }
}

extension SourceSpecification.Secrets: Collection {

    public typealias Element = Dictionary<Secret.Namespace, ArraySlice<Secret>>.Element
    public typealias Index = Dictionary<Secret.Namespace, ArraySlice<Secret>>.Index

    public var startIndex: Index {
        secrets.startIndex
    }

    public var endIndex: Index {
        secrets.endIndex
    }

    public subscript(position: Index) -> Element {
        secrets[position]
    }

    public func index(after index: Index) -> Index {
        secrets.index(after: index)
    }
}

extension SourceSpecification.Secrets: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (Secret.Namespace, ArraySlice<Secret>)...) {
        self.init(.init(uniqueKeysWithValues: elements))
    }
}
