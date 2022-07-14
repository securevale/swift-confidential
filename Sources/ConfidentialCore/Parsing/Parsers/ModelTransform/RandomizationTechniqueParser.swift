import Parsing

struct RandomizationTechniqueParser: Parser {

    typealias GenerateNonce = () throws -> UInt64
    typealias Technique = SourceSpecification.ObfuscationStep.Technique

    private let generateNonce: GenerateNonce

    init(generateNonce: @escaping GenerateNonce = { try UInt64.secureRandom() }) {
        self.generateNonce = generateNonce
    }

    func parse(_ input: inout Substring) throws -> Technique {
        try Parse {
            Whitespace()
            C.Parsing.Keywords.shuffle
            End()
        }.parse(&input)

        return .randomization(nonce: try generateNonce())
    }
}
