import ConfidentialKit
import Parsing

struct SecretNamespaceParser: Parser {

    typealias Namespace = SourceSpecification.Secret.Namespace

    private enum NamespaceKind: Equatable {
        case create
        case extend
    }

    func parse(_ input: inout Substring) throws -> Namespace {
        guard !input.isEmpty else {
            let defaultNamespaceInfo = TypeInfo(of: Obfuscation.Secret.self)
            return .extend(
                identifier: defaultNamespaceInfo.fullyQualifiedName,
                moduleName: defaultNamespaceInfo.moduleName
            )
        }

        return try Parse {
            Whitespace()
            OneOf {
                C.Parsing.Keywords.create.map { NamespaceKind.create }
                C.Parsing.Keywords.extend.map { NamespaceKind.extend }
            }
        }.flatMap { namespaceKind in
            Always(namespaceKind)
            Whitespace()
            Prefix(1...) { !$0.isWhitespace }
            if case .extend = namespaceKind {
                Optionally {
                    Whitespace()
                    C.Parsing.Keywords.from
                    Whitespace()
                    Prefix(1...) { !$0.isWhitespace }
                }
            }
            End()
        }.map { namespaceKind, identifier, moduleName -> Namespace in
            switch namespaceKind {
            case .create:
                return .create(identifier: .init(identifier))
            case .extend:
                return .extend(identifier: .init(identifier), moduleName: moduleName?.map(String.init))
            }
        }.parse(&input)
    }
}
