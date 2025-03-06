import Parsing

package struct SourceFileSpecParser<AlgorithmParser: Parser, SecretsParser: Parser>: Parser
where
    AlgorithmParser.Input == Configuration,
    AlgorithmParser.Output == SourceFileSpec.Algorithm,
    SecretsParser.Input == Configuration,
    SecretsParser.Output == SourceFileSpec.Secrets
{ // swiftlint:disable:this opening_brace

    private let algorithmParser: AlgorithmParser
    private let secretsParser: SecretsParser

    init(algorithmParser: AlgorithmParser, secretsParser: SecretsParser) {
        self.algorithmParser = algorithmParser
        self.secretsParser = secretsParser
    }

    package func parse(_ input: inout Configuration) throws -> SourceFileSpec {
        let spec = SourceFileSpec(
            algorithm: try algorithmParser.parse(&input),
            experimentalMode: input.isExperimentalModeEnabled,
            internalImport: input.isInternalImportEnabled,
            secrets: try secretsParser.parse(&input)
        )
        input.defaultAccessModifier = nil
        input.defaultNamespace = nil
        input.experimentalMode = nil
        input.internalImport = nil

        return spec
    }
}

package extension Parsers.ModelTransform {

    typealias SourceFileSpec = SourceFileSpecParser
}
