import Parsing

struct RandomizationTechniqueParser: Parser {

    typealias Technique = SourceSpecification.ObfuscationStep.Technique

    func parse(_ input: inout Substring) throws -> Technique {
        try Parse(Technique.randomization) {
            Whitespace(.horizontal)
            C.Parsing.Keywords.shuffle
            End()
        }.parse(&input)
    }
}
