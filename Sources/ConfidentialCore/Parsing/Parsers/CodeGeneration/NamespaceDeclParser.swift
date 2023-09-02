import Parsing
import SwiftSyntax
import SwiftSyntaxBuilder

struct NamespaceDeclParser<MembersParser: Parser, DeobfuscateDataFunctionDeclParser: Parser>: Parser
where
    MembersParser.Input == ArraySlice<SourceSpecification.Secret>,
    MembersParser.Output == [ExpressibleAsMemberDeclListItem],
    DeobfuscateDataFunctionDeclParser.Input == SourceSpecification.Algorithm,
    DeobfuscateDataFunctionDeclParser.Output == ExpressibleAsMemberDeclListItem
{ // swiftlint:disable:this opening_brace

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

                let decl: ExpressibleAsCodeBlockItem
                switch namespace {
                case let .create(identifier):
                    decl = try enumDecl(
                        identifier: identifier,
                        secrets: &secrets,
                        deobfuscateDataFunctionDecl: deobfuscateDataFunctionDecl
                    )
                case let .extend(identifier, moduleName):
                    let extendedTypeIdentifier = [moduleName, identifier]
                        .compactMap { $0 }
                        .joined(separator: ".")
                    decl = try extensionDecl(
                        extendedTypeIdentifier: extendedTypeIdentifier,
                        secrets: &secrets,
                        deobfuscateDataFunctionDecl: deobfuscateDataFunctionDecl
                    )
                }
                input.secrets[namespace] = secrets.isEmpty ? nil : secrets

                return decl
            }

        return codeBlocks
    }
}

private extension NamespaceDeclParser {

    func enumDecl(
        identifier: String,
        secrets: inout ArraySlice<SourceSpecification.Secret>,
        deobfuscateDataFunctionDecl: ExpressibleAsMemberDeclListItem
    ) throws -> EnumDecl {
        let accessModifier: TokenSyntax = secrets
            .map(\.accessModifier)
            .contains(.public)
        ? .public
        : .internal

        return .init(
            enumKeyword: .enum,
            identifier: identifier,
            members: try members(from: &secrets, with: deobfuscateDataFunctionDecl),
            modifiersBuilder: {
                DeclModifier(name: accessModifier.withLeadingTrivia(.newlines(1)))
            }
        )
    }

    func extensionDecl(
        extendedTypeIdentifier: String,
        secrets: inout ArraySlice<SourceSpecification.Secret>,
        deobfuscateDataFunctionDecl: ExpressibleAsMemberDeclListItem
    ) throws -> ExtensionDecl {
        .init(
            modifiers: .none,
            extensionKeyword: .extension.withLeadingTrivia(.newlines(1)),
            extendedType: SimpleTypeIdentifier(extendedTypeIdentifier),
            members: try members(from: &secrets, with: deobfuscateDataFunctionDecl)
        )
    }

    func members(
        from secrets: inout ArraySlice<SourceSpecification.Secret>,
        with deobfuscateDataFunctionDecl: ExpressibleAsMemberDeclListItem
    ) throws -> MemberDeclBlock {
        var declarations = try membersParser.parse(&secrets)
        declarations.append(deobfuscateDataFunctionDecl)

        return .init(
            leftBrace: .leftBrace.withLeadingTrivia(.spaces(1)),
            members: MemberDeclList(declarations)
        )
    }
}
