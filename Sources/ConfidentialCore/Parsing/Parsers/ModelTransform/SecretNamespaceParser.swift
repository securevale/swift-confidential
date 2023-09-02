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
                identifier: defaultNamespaceInfo.fullName,
                moduleName: defaultNamespaceInfo.moduleName
            )
        }

        return try Parse(input: Substring.self) {
            Whitespace(.horizontal)
            OneOf {
                C.Parsing.Keywords.create.map { NamespaceKind.create }
                C.Parsing.Keywords.extend.map { NamespaceKind.extend }
            }
        }
        .flatMap { namespaceKind in
            Always(namespaceKind)
            Whitespace(1..., .horizontal)
            Prefix(1...) { !$0.isWhitespace }
            if case .extend = namespaceKind {
                OneOf {
                    Parse(input: Substring.self, Substring?.some) {
                        Whitespace(1..., .horizontal)
                        C.Parsing.Keywords.from
                        Whitespace(1..., .horizontal)
                        Prefix(1...) { !$0.isWhitespace }
                        End()
                    }
                    End().map { Substring?.none }
                }
            } else {
                End().map { Substring?.none }
            }
        }
        .map { namespaceKind, identifier, moduleName -> Namespace in
            switch namespaceKind {
            case .create:
                return .create(identifier: .init(identifier))
            case .extend:
                return .extend(identifier: .init(identifier), moduleName: moduleName.map(String.init))
            }
        }
        .parse(&input)
    }
}
