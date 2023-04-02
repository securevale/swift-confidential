import ConfidentialKit
import Parsing

struct CompressionTechniqueParser: Parser {

    typealias Technique = SourceSpecification.ObfuscationStep.Technique

    private typealias Algorithm = Obfuscation.Compression.CompressionAlgorithm

    func parse(_ input: inout Substring) throws -> Technique {
        try Parse(input: Substring.self, Technique.compression(algorithm:)) {
            Parse(input: Substring.self) {
                Whitespace(.horizontal)
                C.Parsing.Keywords.compress
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
