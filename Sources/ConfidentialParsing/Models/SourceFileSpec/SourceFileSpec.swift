import ConfidentialCore

package struct SourceFileSpec: Equatable {
    var experimentalMode: Bool  // <- reserved for future use
    var internalImport: Bool
    var secrets: Secrets
}

package extension SourceFileSpec {

    struct Secret {
        let accessModifier: AccessModifier
        let algorithm: Algorithm
        let name: String
        let value: Value
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

extension SourceFileSpec.Secret: Hashable {

    package static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.accessModifier == rhs.accessModifier &&
        lhs.algorithm == rhs.algorithm &&
        lhs.name == rhs.name &&
        lhs.value == rhs.value
    }

    package func hash(into hasher: inout Hasher) {
        hasher.combine(accessModifier)
        hasher.combine(algorithm)
        hasher.combine(name)
        hasher.combine(value)
    }
}

extension SourceFileSpec.Secret {

    typealias Algorithm = Obfuscation.AlgorithmSpecifier

    enum Value: Hashable {

        case string(String)
        case stringArray(Array<String>)

        init(from value: Configuration.Secret.Value) {
            self = switch value {
            case let .string(value): .string(value)
            case let .stringArray(value): .stringArray(value)
            }
        }
    }

    enum AccessModifier: String, CaseIterable {
        case `internal`
        case `package`
        case `public`
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
