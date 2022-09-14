import ConfidentialKit
import Foundation
import Parsing

struct SecretsParser<NamespaceParser: Parser>: Parser
where
    NamespaceParser.Input == Substring,
    NamespaceParser.Output == SourceSpecification.Secret.Namespace
{ // swiftlint:disable:this opening_brace

    typealias Secrets = SourceSpecification.Secrets

    private let namespaceParser: NamespaceParser
    private let secretValueEncoder: DataEncoder

    init(
        namespaceParser: NamespaceParser,
        secretValueEncoder: DataEncoder = JSONEncoder()
    ) {
        self.namespaceParser = namespaceParser
        self.secretValueEncoder = secretValueEncoder
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
                    name: secret.name,
                    data: try secretValueEncoder.encode(secret.value.underlyingValue),
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
