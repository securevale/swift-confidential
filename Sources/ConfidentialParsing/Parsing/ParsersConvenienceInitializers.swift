import ConfidentialCore
import Parsing
import SwiftSyntax
import class Yams.YAMLDecoder

package typealias AnySourceFileSpecParser = AnyParser<Configuration, SourceFileSpec>
package typealias AnySourceFileParser = AnyParser<SourceFileSpec, SourceFileSyntax>

package extension ConfidentialParser
where
    SourceFileSpecParser == AnySourceFileSpecParser,
    SourceFileParser == AnySourceFileParser
{ // swiftlint:disable:this opening_brace

    init() {
        self.init(
            configurationDecoder: YAMLDecoder(),
            sourceFileSpecParser: ConfidentialParsing.SourceFileSpecParser().eraseToAnyParser(),
            sourceFileParser: ConfidentialParsing.SourceFileParser().eraseToAnyParser()
        )
    }
}

private typealias AnySecretsParser = AnyParser<Configuration, SourceFileSpec.Secrets>

private extension SourceFileSpecParser
where
    SecretsParser == AnySecretsParser
{ // swiftlint:disable:this opening_brace

    typealias AnyObfuscationStepParser = AnyParser<Substring, Obfuscation.Step>
    typealias OneOfManyObfuscationSteps = OneOfBuilder<Substring, Obfuscation.Step>.OneOf2<
        OneOfBuilder<Substring, Obfuscation.Step>.OneOf2<AnyObfuscationStepParser, AnyObfuscationStepParser>,
        AnyObfuscationStepParser
    >

    init() {
        self.init(
            secretsParser: ConfidentialParsing.SecretsParser(
                accessModifierParser: SecretAccessModifierParser(),
                algorithmParser: ConfidentialParsing.AlgorithmParser(
                    obfuscationStepsParser: ObfuscationStepsParser<OneOfManyObfuscationSteps>(
                        with: {
                            CompressStepParser().eraseToAnyParser()
                            EncryptStepParser().eraseToAnyParser()
                            ShuffleStepParser().eraseToAnyParser()
                        }
                    )
                )
                .eraseToAnyParser(),
                namespaceParser: SecretNamespaceParser()
            )
            .eraseToAnyParser()
        )
    }
}

private typealias AnyCodeBlockParser = AnyParser<SourceFileSpec, [CodeBlockItemSyntax]>

private extension SourceFileParser
where
    CodeBlockParsers == AnyCodeBlockParser
{ // swiftlint:disable:this opening_brace

    init() {
        self.init {
            Parse(input: SourceFileSpec.self) {
                ImportDeclParser()
                NamespaceDeclParser(
                    membersParser: NamespaceMembersParser(
                        secretDeclParser: SecretVariableDeclParser()
                    )
                )
            }
            .map { imports, namespaces in
                imports + namespaces
            }
            .eraseToAnyParser()
        }
    }
}
