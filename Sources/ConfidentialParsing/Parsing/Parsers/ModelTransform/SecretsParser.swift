import Parsing

struct SecretsParser<NamespaceParser: Parser, AccessModifierParser: Parser, AlgorithmParser: Parser>: Parser
where
    NamespaceParser.Input == Substring,
    NamespaceParser.Output == SourceFileSpec.Secret.Namespace,
    AccessModifierParser.Input == Substring,
    AccessModifierParser.Output == SourceFileSpec.Secret.AccessModifier,
    AlgorithmParser.Input == Configuration.Algorithm,
    AlgorithmParser.Output == SourceFileSpec.Secret.Algorithm
{ // swiftlint:disable:this opening_brace

    typealias Output = SourceFileSpec.Secrets

    private let namespaceParser: NamespaceParser
    private let accessModifierParser: AccessModifierParser
    private let algorithmParser: AlgorithmParser

    init(
        namespaceParser: NamespaceParser,
        accessModifierParser: AccessModifierParser,
        algorithmParser: AlgorithmParser
    ) {
        self.namespaceParser = namespaceParser
        self.accessModifierParser = accessModifierParser
        self.algorithmParser = algorithmParser
    }

    func parse(_ input: inout Configuration) throws -> Output {
        guard !input.secrets.isEmpty else {
            throw ParsingError.assertionFailed(description: "`secrets` list must not be empty.")
        }

        var parsedSecretsCount: Int = .zero
        let algorithm = try input.algorithm.map { algorithm in
            try algorithmParser.parse(algorithm)
        }
        let output: Output
        do {
            output = try input.secrets.reduce(into: .init(), { secrets, secret in
                let namespace = try namespaceParser.parse(
                    secret.namespace ?? input.defaultNamespace ?? ""
                )
                let secret = SourceFileSpec.Secret(
                    accessModifier: try accessModifierParser.parse(
                        secret.accessModifier ?? input.defaultAccessModifier ?? ""
                    ),
                    algorithm: algorithm ?? .random,
                    name: secret.name,
                    value: .init(from: secret.value)
                )
                parsedSecretsCount += 1

                switch secrets[namespace]?.append(secret) {
                case .none:
                    secrets[namespace] = [secret]
                case .some:
                    return
                }
            })
            input.secrets.removeFirst(parsedSecretsCount)
        } catch {
            input.secrets.removeFirst(parsedSecretsCount)
            throw error
        }
        input.algorithm = nil

        return output
    }
}
