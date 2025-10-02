import Parsing

struct ShuffleStepParser: Parser {

    typealias ObfuscationStep = SourceFileSpec.ObfuscationStep

    func parse(_ input: inout Substring) throws -> ObfuscationStep {
        try Parse(input: Substring.self, ObfuscationStep.shuffle) {
            Whitespace(.horizontal)
            C.Parsing.Keywords.shuffle
            End()
        }.parse(&input)
    }
}
