import ConfidentialCore
import Parsing

struct ShuffleStepParser: Parser {

    func parse(_ input: inout Substring) throws -> Obfuscation.Step {
        try Parse(input: Substring.self, Obfuscation.Step.shuffle) {
            Whitespace(.horizontal)
            C.Parsing.Keywords.shuffle
            End()
        }.parse(&input)
    }
}
