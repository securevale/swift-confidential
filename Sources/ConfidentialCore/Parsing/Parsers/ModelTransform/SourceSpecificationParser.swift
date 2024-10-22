import Parsing

package struct SourceSpecificationParser<AlgorithmParser: Parser, SecretsParser: Parser>: Parser
where
    AlgorithmParser.Input == Configuration,
    AlgorithmParser.Output == SourceSpecification.Algorithm,
    SecretsParser.Input == Configuration,
    SecretsParser.Output == SourceSpecification.Secrets
{ // swiftlint:disable:this opening_brace

    private let algorithmParser: AlgorithmParser
    private let secretsParser: SecretsParser

    init(algorithmParser: AlgorithmParser, secretsParser: SecretsParser) {
        self.algorithmParser = algorithmParser
        self.secretsParser = secretsParser
    }

    package func parse(_ input: inout Configuration) throws -> SourceSpecification {
        let spec = SourceSpecification(
            algorithm: try algorithmParser.parse(&input),
            implementationOnlyImport: input.implementationOnlyImport ?? false,
            secrets: try secretsParser.parse(&input)
        )
        input.defaultAccessModifier = nil
        input.defaultNamespace = nil
        input.implementationOnlyImport = nil

        return spec
    }
}

package extension Parsers.ModelTransform {

    typealias SourceSpecification = SourceSpecificationParser
}
