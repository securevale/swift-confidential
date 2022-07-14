import ConfidentialKit
import Parsing

struct EncryptionTechniqueParser: Parser {

    typealias Technique = SourceSpecification.ObfuscationStep.Technique

    private typealias Algorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm

    func parse(_ input: inout Substring) throws -> Technique {
        try Parse {
            Parse {
                Whitespace()
                C.Parsing.Keywords.encrypt
                Whitespace(1...)
                C.Parsing.Keywords.using
                Whitespace(1...)
            }
            OneOf {
                for algorithm in Algorithm.allCases {
                    algorithm.description.map { algorithm }
                }
            }
            End()
        }.map {
            .encryption(algorithm: $0)
        }.parse(&input)
    }
}
