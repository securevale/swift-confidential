import Parsing

struct ObfuscationStepsParser<ObfuscationStepParser: Parser>: Parser
where
    ObfuscationStepParser.Input == Substring,
    ObfuscationStepParser.Output == SourceFileSpec.ObfuscationStep
{ // swiftlint:disable:this opening_brace

    typealias ObfuscationStep = SourceFileSpec.ObfuscationStep

    private let obfuscationStepParser: ObfuscationStepParser

    init(
        @OneOfBuilder<Substring, ObfuscationStep> with obfuscationStepParser: () -> ObfuscationStepParser
    ) {
        self.obfuscationStepParser = obfuscationStepParser()
    }

    func parse(_ input: inout ArraySlice<String>) throws -> ArraySlice<ObfuscationStep> {
        var parsedObfuscationStepsCount: Int = .zero
        let output: [ObfuscationStep]
        do {
            output = try input.reduce(into: .init(), { steps, step in
                let obfuscationStep = try obfuscationStepParser.parse(step)
                parsedObfuscationStepsCount += 1

                steps.append(obfuscationStep)
            })
            input.removeFirst(parsedObfuscationStepsCount)
        } catch {
            input.removeFirst(parsedObfuscationStepsCount)
            throw error
        }

        return output[...]
    }
}
