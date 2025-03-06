import Parsing

struct RandomizationTechniqueParser: Parser {

    typealias Technique = SourceFileSpec.ObfuscationStep.Technique

    func parse(_ input: inout Substring) throws -> Technique {
        try Parse(input: Substring.self, Technique.randomization) {
            Whitespace(.horizontal)
            C.Parsing.Keywords.shuffle
            End()
        }.parse(&input)
    }
}
