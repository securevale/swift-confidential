import ConfidentialCore
import Parsing
import SwiftSyntax

package typealias AnySecretsParser = AnyParser<Configuration, SourceFileSpec.Secrets>

package extension Parsers.ModelTransform.SourceFileSpec
where
    SecretsParser == AnySecretsParser
{ // swiftlint:disable:this opening_brace

    private typealias AnyObfuscationStepParser = AnyParser<Substring, Obfuscation.Step>
    private typealias OneOfManyObfuscationSteps = OneOfBuilder<Substring, Obfuscation.Step>.OneOf2<
        OneOfBuilder<Substring, Obfuscation.Step>.OneOf2<AnyObfuscationStepParser, AnyObfuscationStepParser>,
        AnyObfuscationStepParser
    >

    init() {
        self.init(
            secretsParser: ConfidentialParsing.SecretsParser(
                namespaceParser: SecretNamespaceParser(),
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
                .eraseToAnyParser()
            )
            .eraseToAnyParser()
        )
    }
}

package typealias AnyCodeBlockParser = AnyParser<SourceFileSpec, [CodeBlockItemSyntax]>

package extension Parsers.CodeGeneration.SourceFile
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
