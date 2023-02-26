import Parsing
import SwiftSyntaxBuilder

public typealias AnyAlgorithmParser = AnyParser<Configuration, SourceSpecification.Algorithm>
public typealias AnySecretsParser = AnyParser<Configuration, SourceSpecification.Secrets>

public extension Parsers.ModelTransform.SourceSpecification
where
    AlgorithmParser == AnyAlgorithmParser,
    SecretsParser == AnySecretsParser
{ // swiftlint:disable:this opening_brace

#if swift(>=5.7)
    private typealias AnyTechniqueParser = AnyParser<Substring, SourceSpecification.ObfuscationStep.Technique>
    private typealias OneOfManyTechniques = OneOfBuilder.OneOf2<
        OneOfBuilder.OneOf2<AnyTechniqueParser, AnyTechniqueParser>,
        AnyTechniqueParser
    >
#else
    private typealias OneOfManyTechniques = Parsers.OneOfMany<
        AnyParser<Substring, SourceSpecification.ObfuscationStep.Technique>
    >
#endif

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

public typealias AnyCodeBlockParser = AnyParser<SourceSpecification, [ExpressibleAsCodeBlockItem]>

public extension Parsers.CodeGeneration.SourceFile
where
    CodeBlockParsers == AnyCodeBlockParser
{ // swiftlint:disable:this opening_brace

    init() {
        self.init {
            NamespaceDeclParser(
                membersParser: NamespaceMembersParser(
                    secretDeclParser: SecretDeclParser()
                ),
                deobfuscateDataFunctionDeclParser: DeobfuscateDataFunctionDeclParser(functionNestingLevel: 1)
            )
            .eraseToAnyParser()
        }
    }
}
