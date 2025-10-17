import ConfidentialCore
import Parsing

struct AlgorithmParser<ObfuscationStepsParser: Parser>: Parser
where
    ObfuscationStepsParser.Input == ArraySlice<String>,
    ObfuscationStepsParser.Output == Array<Obfuscation.Step>
{ // swiftlint:disable:this opening_brace

    typealias Output = SourceFileSpec.Secret.Algorithm

    private let obfuscationStepsParser: ObfuscationStepsParser

    init(obfuscationStepsParser: ObfuscationStepsParser) {
        self.obfuscationStepsParser = obfuscationStepsParser
    }

    func parse(_ input: inout Configuration.Algorithm) throws -> Output {
        let output: Output
        switch input {
        case let .random(algorithm):
            try Parse(input: Substring.self) {
                Whitespace(.horizontal)
                C.Parsing.Keywords.random
                End()
            }
            .parse(algorithm)
            output = .random
        case var .custom(algorithm):
            do {
                output = .custom(
                    try obfuscationStepsParser.parse(&algorithm)
                )
            } catch {
                input = .custom(algorithm)
                throw error
            }
            input = .custom([])
        }

        return output
    }
}
