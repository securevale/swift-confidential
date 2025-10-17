import Parsing

package struct SourceFileSpecParser<SecretsParser: Parser>: Parser
where
    SecretsParser.Input == Configuration,
    SecretsParser.Output == SourceFileSpec.Secrets
{ // swiftlint:disable:this opening_brace

    private let secretsParser: SecretsParser

    init(secretsParser: SecretsParser) {
        self.secretsParser = secretsParser
    }

    package func parse(_ input: inout Configuration) throws -> SourceFileSpec {
        let spec = SourceFileSpec(
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
