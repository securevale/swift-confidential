import Parsing

struct ObfuscationStepParser<TechniqueParsers: Parser>: Parser
where
TechniqueParsers.Input == Substring,
TechniqueParsers.Output == SourceSpecification.ObfuscationStep.Technique
{
    typealias ObfuscationStep = SourceSpecification.ObfuscationStep

    private let techniqueParsers: TechniqueParsers

    init(@OneOfBuilder with build: () -> TechniqueParsers) {
        self.techniqueParsers = build()
    }

    func parse(_ input: inout Substring) throws -> ObfuscationStep {
        try techniqueParsers
            .map(ObfuscationStep.init(technique:))
            .parse(&input)
    }
}
