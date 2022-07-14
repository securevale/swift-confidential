import Parsing
import SwiftSyntaxBuilder

struct NamespaceDeclParser<MembersParser: Parser, DeobfuscateDataFunctionDeclParser: Parser>: Parser
where
MembersParser.Input == ArraySlice<SourceSpecification.Secret>,
MembersParser.Output == [ExpressibleAsMemberDeclListItem],
DeobfuscateDataFunctionDeclParser.Input == SourceSpecification.Algorithm,
DeobfuscateDataFunctionDeclParser.Output == ExpressibleAsMemberDeclListItem
{

    private let membersParser: MembersParser
    private let deobfuscateDataFunctionDeclParser: DeobfuscateDataFunctionDeclParser

    init(
        membersParser: MembersParser,
        deobfuscateDataFunctionDeclParser: DeobfuscateDataFunctionDeclParser
    ) {
        self.membersParser = membersParser
        self.deobfuscateDataFunctionDeclParser = deobfuscateDataFunctionDeclParser
    }

    func parse(_ input: inout SourceSpecification) throws -> [ExpressibleAsCodeBlockItem] {
        let deobfuscateDataFunctionDecl = try deobfuscateDataFunctionDeclParser.parse(&input.algorithm)
        let codeBlocks = try input.secrets.namespaces
            .map { namespace -> ExpressibleAsCodeBlockItem in
                guard var secrets = input.secrets[namespace] else {
                    fatalError("Unexpected source specification integrity violation")
                }

                var declarations = try membersParser.parse(&secrets)
                declarations.append(deobfuscateDataFunctionDecl)
                let members = MemberDeclBlock(
                    leftBrace: .leftBrace.withLeadingTrivia(.spaces(1)),
                    members: MemberDeclList(declarations)
                )
                let decl: ExpressibleAsCodeBlockItem
                switch namespace {
                case let .create(identifier):
                    decl = EnumDecl(
                        enumKeyword: .enum.withLeadingTrivia(.newlines(1)),
                        identifier: identifier,
                        members: members
                    )
                case let .extend(identifier, _):
                    decl = ExtensionDecl(
                        modifiers: .none,
                        extensionKeyword: .extension.withLeadingTrivia(.newlines(1)),
                        extendedType: SimpleTypeIdentifier(identifier),
                        members: members
                    )
                }
                input.secrets[namespace] = secrets.isEmpty ? nil : secrets

                return decl
            }

        return codeBlocks
    }
}
