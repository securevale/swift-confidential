import ConfidentialCore
import Parsing

struct ObfuscationStepsParser<ObfuscationStepParser: Parser>: Parser
where
    ObfuscationStepParser.Input == Substring,
    ObfuscationStepParser.Output == Obfuscation.Step
{ // swiftlint:disable:this opening_brace

    private let obfuscationStepParser: ObfuscationStepParser

    init(
        @OneOfBuilder<Substring, Obfuscation.Step> with obfuscationStepParser: () -> ObfuscationStepParser
    ) {
        self.obfuscationStepParser = obfuscationStepParser()
    }

    func parse(_ input: inout ArraySlice<String>) throws -> Array<Obfuscation.Step> {
        var parsedObfuscationStepsCount: Int = .zero
        let output: [Obfuscation.Step]
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

        return output
    }
}
