import Parsing
import SwiftSyntaxBuilder

public typealias AnyAlgorithmParser = AnyParser<Configuration, SourceSpecification.Algorithm>
public typealias AnySecretsParser = AnyParser<Configuration, SourceSpecification.Secrets>

public extension Parsers.ModelTransform.SourceSpecification
where
AlgorithmParser == AnyAlgorithmParser,
SecretsParser == AnySecretsParser {

    private typealias OneOfManyTechniques = Parsers.OneOfMany<AnyParser<Substring, SourceSpecification.ObfuscationStep.Technique>>

    init() {
        self.init(
            algorithmParser: ConfidentialCore.AlgorithmParser(
                obfuscationStepParser: ObfuscationStepParser<OneOfManyTechniques> {
                    CompressionTechniqueParser().eraseToAnyParser()
                    EncryptionTechniqueParser().eraseToAnyParser()
                    RandomizationTechniqueParser().eraseToAnyParser()
                }
            ).eraseToAnyParser(),
            secretsParser: ConfidentialCore.SecretsParser(
                namespaceParser: SecretNamespaceParser()
            ).eraseToAnyParser()
        )
    }
}

public typealias AnyCodeBlockParser = AnyParser<SourceSpecification, [ExpressibleAsCodeBlockItem]>

public extension Parsers.CodeGeneration.SourceFile
where
CodeBlockParsers == AnyCodeBlockParser {

    init() {
        self.init {
            NamespaceDeclParser(
                membersParser: NamespaceMembersParser(
                    secretDeclParser: SecretDeclParser()
                ),
                deobfuscateDataFunctionDeclParser: DeobfuscateDataFunctionDeclParser(functionNestingLevel: 1)
            ).eraseToAnyParser()
        }
    }
}
