import Parsing
import SwiftSyntax

struct NamespaceDeclParser<MembersParser: Parser, DeobfuscateDataFunctionDeclParser: Parser>: Parser
where
    MembersParser.Input == ArraySlice<SourceFileSpec.Secret>,
    MembersParser.Output == [MemberBlockItemSyntax],
    DeobfuscateDataFunctionDeclParser.Input == SourceFileSpec.Algorithm,
    DeobfuscateDataFunctionDeclParser.Output == any DeclSyntaxProtocol
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

    func parse(_ input: inout SourceFileSpec) throws -> [CodeBlockItemSyntax] {
        let deobfuscateDataFunctionDecl = try deobfuscateDataFunctionDeclParser.parse(&input.algorithm)
        let codeBlocks = try input.secrets.namespaces
            .map { namespace -> CodeBlockItemSyntax in
                guard var secrets = input.secrets[namespace] else {
                    fatalError("Unexpected source file spec integrity violation")
                }

                let decl: any DeclSyntaxProtocol
                switch namespace {
                case let .create(identifier):
                    decl = try enumDecl(
                        identifier: identifier,
                        secrets: &secrets,
                        deobfuscateDataFunctionDecl: deobfuscateDataFunctionDecl
                    )
                case let .extend(identifier, moduleName):
                    let extendedTypeIdentifier: String = [moduleName, identifier]
                        .compactMap { $0 }
                        .joined(separator: ".")
                    decl = try extensionDecl(
                        extendedTypeIdentifier: extendedTypeIdentifier,
                        secrets: &secrets,
                        deobfuscateDataFunctionDecl: deobfuscateDataFunctionDecl
                    )
                }
                input.secrets[namespace] = secrets.isEmpty ? nil : secrets

                return .init(leadingTrivia: .newline, item: .init(decl))
            }

        return codeBlocks
    }
}

private extension NamespaceDeclParser {

    func enumDecl(
        identifier: String,
        secrets: inout ArraySlice<SourceFileSpec.Secret>,
        deobfuscateDataFunctionDecl: some DeclSyntaxProtocol
    ) throws -> EnumDeclSyntax {
        let accessModifiers = Set(secrets.map(\.accessModifier))
        let accessModifier: TokenSyntax = if accessModifiers.contains(.public) {
            .keyword(.public)
        } else if accessModifiers.contains(.package) {
            .keyword(.package)
        } else {
            .keyword(.internal)
        }

        return .init(
            leadingTrivia: .newline,
            modifiers: .init {
                DeclModifierSyntax(name: accessModifier)
            },
            name: .identifier(identifier),
            memberBlock: try memberBlock(from: &secrets, with: deobfuscateDataFunctionDecl)
        )
    }

    func extensionDecl(
        extendedTypeIdentifier: String,
        secrets: inout ArraySlice<SourceFileSpec.Secret>,
        deobfuscateDataFunctionDecl: some DeclSyntaxProtocol
    ) throws -> ExtensionDeclSyntax {
        .init(
            leadingTrivia: .newline,
            extendedType: IdentifierTypeSyntax(name: .identifier(extendedTypeIdentifier)),
            memberBlock: try memberBlock(from: &secrets, with: deobfuscateDataFunctionDecl)
        )
    }

    func memberBlock(
        from secrets: inout ArraySlice<SourceFileSpec.Secret>,
        with deobfuscateDataFunctionDecl: some DeclSyntaxProtocol
    ) throws -> MemberBlockSyntax {
        var declarations = try membersParser.parse(&secrets)
        declarations.append(
            .init(
                leadingTrivia: .newline,
                decl: deobfuscateDataFunctionDecl
            )
        )

        return .init(
            leftBrace: .leftBraceToken(leadingTrivia: .spaces(1)),
            members: MemberBlockItemListSyntax(declarations)
        )
    }
}
