import ConfidentialKit
import ConfidentialUtils
import Foundation
import Parsing

struct SecretsParser<NamespaceParser: Parser, AccessModifierParser: Parser>: Parser
where
    NamespaceParser.Input == Substring,
    NamespaceParser.Output == SourceFileSpec.Secret.Namespace,
    AccessModifierParser.Input == Substring,
    AccessModifierParser.Output == SourceFileSpec.Secret.AccessModifier
{ // swiftlint:disable:this opening_brace

    typealias GenerateNonce = () throws -> Obfuscation.Nonce
    typealias Secrets = SourceFileSpec.Secrets

    private let namespaceParser: NamespaceParser
    private let accessModifierParser: AccessModifierParser
    private let secretValueEncoder: any DataEncoder
    private let generateNonce: GenerateNonce

    init(
        namespaceParser: NamespaceParser,
        accessModifierParser: AccessModifierParser,
        secretValueEncoder: any DataEncoder = JSONEncoder(),
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
                let secret = SourceFileSpec.Secret(
                    accessModifier: try accessModifierParser.parse(
                        secret.accessModifier ?? input.defaultAccessModifier ?? ""
                    ),
                    name: secret.name,
                    data: try secretValueEncoder.encode(secret.value.underlyingValue),
                    nonce: try generateNonce(),
                    dataProjectionAttribute: dataProjectionAttribute(
                        for: secret.value,
                        experimentalMode: input.isExperimentalModeEnabled
                    )
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

    func dataProjectionAttribute(
        for value: Configuration.Secret.Value,
        experimentalMode: Bool
    ) -> SourceFileSpec.Secret.DataProjectionAttribute
    {
        typealias DataTypes = Configuration.Secret.Value.DataTypes

        let baseName = C.Code.Generation.obfuscatedMacroFullyQualifiedName
        let genericArgumentTypeInfo: TypeInfo
        switch value {
        case .array:
            genericArgumentTypeInfo = .init(of: DataTypes.Array.self)
        case .singleValue:
            genericArgumentTypeInfo = .init(of: DataTypes.SingleValue.self)
        }
        let name = "\(baseName)<\(genericArgumentTypeInfo.fullyQualifiedName)>"

        return .init(
            name: name,
            arguments: [
                (label: .none, value: C.Code.Generation.deobfuscateDataFuncName)
            ]
        )
    }
}
