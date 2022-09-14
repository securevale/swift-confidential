import Parsing

struct AlgorithmParser<ObfuscationStepParser: Parser>: Parser
where
    ObfuscationStepParser.Input == Substring,
    ObfuscationStepParser.Output == SourceSpecification.ObfuscationStep
{ // swiftlint:disable:this opening_brace

    typealias Algorithm = SourceSpecification.Algorithm

    private let obfuscationStepParser: ObfuscationStepParser

    init(obfuscationStepParser: ObfuscationStepParser) {
        self.obfuscationStepParser = obfuscationStepParser
    }

    func parse(_ input: inout Configuration) throws -> Algorithm {
        var parsedObfuscationStepsCount: Int = .zero
        let output: [ObfuscationStepParser.Output]
        do {
            output = try input.algorithm.reduce(into: .init(), { steps, step in
                let obfuscationStep = try obfuscationStepParser.parse(step)
                parsedObfuscationStepsCount += 1

                steps.append(obfuscationStep)
            })
            input.algorithm.removeFirst(parsedObfuscationStepsCount)
        } catch {
            input.algorithm.removeFirst(parsedObfuscationStepsCount)
            throw error
        }

        return output[...]
    }
}
