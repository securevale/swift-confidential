import Parsing

struct AlgorithmParser<ObfuscationStepsParser: Parser>: Parser
where
    ObfuscationStepsParser.Input == ArraySlice<String>,
    ObfuscationStepsParser.Output == ArraySlice<SourceFileSpec.ObfuscationStep>
{ // swiftlint:disable:this opening_brace

    typealias Algorithm = SourceFileSpec.Algorithm

    private let algorithmGenerator: any AlgorithmGenerator
    private let obfuscationStepsParser: ObfuscationStepsParser

    init(
        algorithmGenerator: any AlgorithmGenerator,
        obfuscationStepsParser: ObfuscationStepsParser
    ) {
        self.algorithmGenerator = algorithmGenerator
        self.obfuscationStepsParser = obfuscationStepsParser
    }

    func parse(_ input: inout Configuration) throws -> Algorithm {
        let output: Algorithm
        switch input.algorithm {
        case .none:
            output = algorithmGenerator.generateAlgorithm()
        case let .random(algorithm):
            try Parse(input: Substring.self) {
                Whitespace(.horizontal)
                C.Parsing.Keywords.random
                End()
            }
            .parse(algorithm)
            output = algorithmGenerator.generateAlgorithm()
        case var .custom(algorithm):
            do {
                output = try obfuscationStepsParser.parse(&algorithm)
            } catch {
                input.algorithm = .custom(algorithm)
                throw error
            }
        }
        input.algorithm = nil

        return output
    }
}
