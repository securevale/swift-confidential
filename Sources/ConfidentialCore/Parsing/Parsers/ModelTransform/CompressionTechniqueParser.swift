import ConfidentialKit
import Parsing

struct CompressionTechniqueParser: Parser {

    typealias Technique = SourceSpecification.ObfuscationStep.Technique

    private typealias Algorithm = Obfuscation.Compression.CompressionAlgorithm

    func parse(_ input: inout Substring) throws -> Technique {
        try Parse {
            Parse {
                Whitespace()
                C.Parsing.Keywords.compress
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
            .compression(algorithm: $0)
        }.parse(&input)
    }
}
