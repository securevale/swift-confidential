import ConfidentialKit
import Parsing

struct EncryptionTechniqueParser: Parser {

    typealias Technique = SourceFileSpec.ObfuscationStep.Technique

    private typealias Algorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm

    func parse(_ input: inout Substring) throws -> Technique {
        try Parse(input: Substring.self, Technique.encryption(algorithm:)) {
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
