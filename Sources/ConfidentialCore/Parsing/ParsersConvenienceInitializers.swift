import Parsing
import SwiftSyntax

package typealias AnyAlgorithmParser = AnyParser<Configuration, SourceFileSpec.Algorithm>
package typealias AnySecretsParser = AnyParser<Configuration, SourceFileSpec.Secrets>

package extension Parsers.ModelTransform.SourceFileSpec
where
    AlgorithmParser == AnyAlgorithmParser,
    SecretsParser == AnySecretsParser
{ // swiftlint:disable:this opening_brace

    private typealias ObfuscationStep = SourceFileSpec.ObfuscationStep
    private typealias AnyObfuscationStepParser = AnyParser<Substring, ObfuscationStep>
    private typealias OneOfManyObfuscationSteps = OneOfBuilder<Substring, ObfuscationStep>.OneOf2<
        OneOfBuilder<Substring, ObfuscationStep>.OneOf2<AnyObfuscationStepParser, AnyObfuscationStepParser>,
        AnyObfuscationStepParser
    >

    init() {
        self.init(
            algorithmParser: ConfidentialCore.AlgorithmParser(
                algorithmGenerator: RandomAlgorithmGenerator(
                    randomNumberGenerator: SystemRandomNumberGenerator()
                ),
                obfuscationStepsParser: ObfuscationStepsParser<OneOfManyObfuscationSteps>(
                    with: {
                        CompressStepParser().eraseToAnyParser()
                        EncryptStepParser().eraseToAnyParser()
                        ShuffleStepParser().eraseToAnyParser()
                    }
                )
            )
            .eraseToAnyParser(),
            secretsParser: ConfidentialCore.SecretsParser(
                namespaceParser: SecretNamespaceParser(),
                accessModifierParser: SecretAccessModifierParser()
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
                    ),
                    deobfuscateDataFunctionDeclParser: DeobfuscateDataFunctionDeclParser(functionNestingLevel: 1)
                )
            }
            .map { imports, namespaces in
                imports + namespaces
            }
            .eraseToAnyParser()
        }
    }
}
