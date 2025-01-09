import Parsing

public struct SourceSpecificationParser<AlgorithmParser: Parser, SecretsParser: Parser>: Parser
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

    public func parse(_ input: inout Configuration) throws -> SourceSpecification {
        let spec = SourceSpecification(
            algorithm: try algorithmParser.parse(&input),
            importAttribute: input.importAttribute,
            secrets: try secretsParser.parse(&input)
        )
        input.defaultAccessModifier = nil
        input.defaultNamespace = nil
        input.implementationOnlyImport = nil

        return spec
    }
}

public extension Parsers.ModelTransform {
    typealias SourceSpecification = SourceSpecificationParser
}

extension Configuration {
    var importAttribute: SourceSpecification.ImportAttribute {
        if let internalImport, internalImport { return .internal }
        if let implementationOnlyImport, implementationOnlyImport { return .implementationOnly }
        return .default
    }
}
