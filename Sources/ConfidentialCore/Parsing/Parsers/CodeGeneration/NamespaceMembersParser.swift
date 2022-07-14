import Parsing
import SwiftSyntaxBuilder

struct NamespaceMembersParser<SecretDeclParser: Parser>: Parser
where
SecretDeclParser.Input == SourceSpecification.Secret,
SecretDeclParser.Output == ExpressibleAsSecretDecl
{

    private let secretDeclParser: SecretDeclParser

    init(secretDeclParser: SecretDeclParser) {
        self.secretDeclParser = secretDeclParser
    }

    func parse(_ input: inout ArraySlice<SourceSpecification.Secret>) throws -> [ExpressibleAsMemberDeclListItem] {
        var parsedSecretsCount: Int = .zero
        let declarations: [SecretDecl]
        do {
            declarations = try input.map { secret in
                let decl = try secretDeclParser.parse(secret).createSecretDecl()
                parsedSecretsCount += 1

                return decl
            }
            input.removeFirst(parsedSecretsCount)
        } catch let error {
            input.removeFirst(parsedSecretsCount)
            throw error
        }

        return declarations
    }
}
