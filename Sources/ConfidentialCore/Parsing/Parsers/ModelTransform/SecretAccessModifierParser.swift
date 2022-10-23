import Parsing

struct SecretAccessModifierParser: Parser {

    typealias AccessModifier = SourceSpecification.Secret.AccessModifier

    func parse(_ input: inout Substring) throws -> AccessModifier {
        guard !input.isEmpty else {
            return .internal
        }

        return try Parse {
            Whitespace(.horizontal)
            AccessModifier.parser()
            End()
        }
        .parse(&input)
    }
}
