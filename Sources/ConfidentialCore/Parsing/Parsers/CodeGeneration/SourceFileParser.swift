import ConfidentialKit
import Foundation
import Parsing
import SwiftSyntaxBuilder

public struct SourceFileParser<CodeBlockParsers: Parser>: Parser
where
CodeBlockParsers.Input == SourceSpecification,
CodeBlockParsers.Output == [ExpressibleAsCodeBlockItem]
{

    private let codeBlockParsers: CodeBlockParsers

    init(@ParserBuilder with build: () -> CodeBlockParsers) {
        self.codeBlockParsers = build()
    }

    public func parse(_ input: inout SourceSpecification) throws -> SourceFileText {
        var statements = Self.makeModuleImportList(from: input.secrets.namespaces)
            .enumerated()
            .map { idx, moduleName -> ExpressibleAsCodeBlockItem in
                ImportDecl(
                    path: AccessPath([AccessPathComponent(name: .identifier(moduleName))])
                )
            }
        statements.append(
            contentsOf: try codeBlockParsers.parse(&input)
        )

        return .init(from: SourceFile(
            statements: CodeBlockItemList(statements),
            eofToken: .eof
        ))
    }
}

private extension SourceFileParser {

    static func makeModuleImportList<Namespaces: Collection>(from namespaces: Namespaces) -> [String]
    where
    Namespaces.Element == SourceSpecification.Secret.Namespace
    {
        let confidentialKitModuleName = TypeInfo(of: Obfuscation.self).moduleName
        let foundationModuleName = TypeInfo(of: Data.self).moduleName
        let defaultModuleNames = [confidentialKitModuleName, foundationModuleName]
        let moduleNames = defaultModuleNames + namespaces
            .compactMap { namespace -> String? in
                guard
                    case let .extend(_, moduleName) = namespace,
                    let moduleName = moduleName,
                    !defaultModuleNames.contains(moduleName)
                else {
                    return nil
                }

                return moduleName
            }

        return moduleNames.sorted()
    }
}

public extension Parsers.CodeGeneration {

    typealias SourceFile = SourceFileParser
}
