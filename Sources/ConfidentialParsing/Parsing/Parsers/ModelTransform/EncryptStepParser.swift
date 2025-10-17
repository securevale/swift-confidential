import ConfidentialCore
import Parsing

struct EncryptStepParser: Parser {

    private typealias Algorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm

    func parse(_ input: inout Substring) throws -> Obfuscation.Step {
        try Parse(input: Substring.self, Obfuscation.Step.encrypt(algorithm:)) {
            Parse(input: Substring.self) {
                Whitespace(.horizontal)
                C.Parsing.Keywords.encrypt
                Whitespace(1..., .horizontal)
                C.Parsing.Keywords.using
                Whitespace(1..., .horizontal)
            }
            OneOf {
                for algorithm in Algorithm.allCases {
                    algorithm.description.map { algorithm }
                }
            }
            End()
        }.parse(&input)
    }
}
