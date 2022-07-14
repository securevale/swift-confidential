import Parsing

public struct SourceSpecificationParser<AlgorithmParser: Parser, SecretsParser: Parser>: Parser
where
AlgorithmParser.Input == Configuration,
AlgorithmParser.Output == SourceSpecification.Algorithm,
SecretsParser.Input == Configuration,
SecretsParser.Output == SourceSpecification.Secrets
{

    private let algorithmParser: AlgorithmParser
    private let secretsParser: SecretsParser

    init(algorithmParser: AlgorithmParser, secretsParser: SecretsParser) {
        self.algorithmParser = algorithmParser
        self.secretsParser = secretsParser
    }

    public func parse(_ input: inout Configuration) throws -> SourceSpecification {
        let spec = SourceSpecification(
            algorithm: try algorithmParser.parse(&input),
            secrets: try secretsParser.parse(&input)
        )
        input.defaultNamespace = nil

        return spec
    }
}

public extension Parsers.ModelTransform {

    typealias SourceSpecification = SourceSpecificationParser
}
