import ConfidentialKit
import Foundation
import Parsing

struct SecretsParser<NamespaceParser: Parser, AccessModifierParser: Parser>: Parser
where
    NamespaceParser.Input == Substring,
    NamespaceParser.Output == SourceSpecification.Secret.Namespace,
    AccessModifierParser.Input == Substring,
    AccessModifierParser.Output == SourceSpecification.Secret.AccessModifier
{ // swiftlint:disable:this opening_brace

    typealias GenerateNonce = () throws -> Obfuscation.Nonce
    typealias Secrets = SourceSpecification.Secrets

    private let namespaceParser: NamespaceParser
    private let accessModifierParser: AccessModifierParser
    private let secretValueEncoder: DataEncoder
    private let generateNonce: GenerateNonce

    init(
        namespaceParser: NamespaceParser,
        accessModifierParser: AccessModifierParser,
        secretValueEncoder: DataEncoder = JSONEncoder(),
        generateNonce: @autoclosure @escaping GenerateNonce = try .secureRandom()
    ) {
        self.namespaceParser = namespaceParser
        self.accessModifierParser = accessModifierParser
        self.secretValueEncoder = secretValueEncoder
        self.generateNonce = generateNonce
    }

    func parse(_ input: inout Configuration) throws -> Secrets {
        guard !input.secrets.isEmpty else {
            throw ParsingError.assertionFailed(description: "`secrets` list must not be empty.")
        }

        var parsedSecretsCount: Int = .zero
        let output: Secrets
        do {
            output = try input.secrets.reduce(into: .init(), { secrets, secret in
                let namespace = try namespaceParser.parse(
                    secret.namespace ?? input.defaultNamespace ?? ""
                )
                let secret = SourceSpecification.Secret(
                    accessModifier: try accessModifierParser.parse(
                        secret.accessModifier ?? input.defaultAccessModifier ?? ""
                    ),
                    name: secret.name,
                    data: try secretValueEncoder.encode(secret.value.underlyingValue),
                    nonce: try generateNonce(),
                    dataAccessWrapperInfo: dataAccessWrapperInfo(for: secret.value)
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

        return output
    }
}

private extension SecretsParser {

    func dataAccessWrapperInfo(for value: Configuration.Secret.Value)
        -> SourceSpecification.Secret.DataAccessWrapperInfo
    {
        typealias DataTypes = Configuration.Secret.Value.DataTypes

        let typeInfo: TypeInfo
        switch value {
        case .array:
            typeInfo = .init(of: Obfuscated<DataTypes.Array>.self)
        case .singleValue:
            typeInfo = .init(of: Obfuscated<DataTypes.SingleValue>.self)
        }

        return .init(
            typeInfo: typeInfo,
            arguments: [
                (label: .none, value: C.Code.Generation.deobfuscateDataFuncName)
            ]
        )
    }
}
