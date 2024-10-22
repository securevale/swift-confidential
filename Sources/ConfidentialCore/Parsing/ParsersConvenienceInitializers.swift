import Parsing
import SwiftSyntax

package typealias AnyAlgorithmParser = AnyParser<Configuration, SourceSpecification.Algorithm>
package typealias AnySecretsParser = AnyParser<Configuration, SourceSpecification.Secrets>

package extension Parsers.ModelTransform.SourceSpecification
where
    AlgorithmParser == AnyAlgorithmParser,
    SecretsParser == AnySecretsParser
{ // swiftlint:disable:this opening_brace

    private typealias Technique = SourceSpecification.ObfuscationStep.Technique
    private typealias AnyTechniqueParser = AnyParser<Substring, Technique>
    private typealias OneOfManyTechniques = OneOfBuilder<Substring, Technique>.OneOf2<
        OneOfBuilder<Substring, Technique>.OneOf2<AnyTechniqueParser, AnyTechniqueParser>,
        AnyTechniqueParser
    >

    init() {
        self.init(
            algorithmParser: ConfidentialCore.AlgorithmParser(
                obfuscationStepParser: ObfuscationStepParser<OneOfManyTechniques> {
                    CompressionTechniqueParser().eraseToAnyParser()
                    EncryptionTechniqueParser().eraseToAnyParser()
                    RandomizationTechniqueParser().eraseToAnyParser()
                }
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

package typealias AnyCodeBlockParser = AnyParser<SourceSpecification, [CodeBlockItemSyntax]>

package extension Parsers.CodeGeneration.SourceFile
where
    CodeBlockParsers == AnyCodeBlockParser
{ // swiftlint:disable:this opening_brace

    init() {
        self.init {
            Parse(input: SourceSpecification.self) {
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
