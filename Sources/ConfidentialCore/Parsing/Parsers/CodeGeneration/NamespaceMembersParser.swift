import Parsing
import SwiftSyntax

struct NamespaceMembersParser<SecretDeclParser: Parser>: Parser
where
    SecretDeclParser.Input == SourceFileSpec.Secret,
    SecretDeclParser.Output == any DeclSyntaxProtocol
{ // swiftlint:disable:this opening_brace

    private let secretDeclParser: SecretDeclParser

    init(secretDeclParser: SecretDeclParser) {
        self.secretDeclParser = secretDeclParser
    }

    func parse(_ input: inout ArraySlice<SourceFileSpec.Secret>) throws -> [MemberBlockItemSyntax] {
        var parsedSecretsCount: Int = .zero
        let declarations: [any DeclSyntaxProtocol]
        do {
            declarations = try input.map { secret in
                let decl = try secretDeclParser.parse(secret)
                parsedSecretsCount += 1

                return decl
            }
            input.removeFirst(parsedSecretsCount)
        } catch {
            input.removeFirst(parsedSecretsCount)
            throw error
        }

        return declarations.map {
            MemberBlockItemSyntax(leadingTrivia: .newline, decl: $0)
        }
    }
}
