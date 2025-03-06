import Parsing

struct SecretAccessModifierParser: Parser {

    typealias AccessModifier = SourceFileSpec.Secret.AccessModifier

    func parse(_ input: inout Substring) throws -> AccessModifier {
        guard !input.isEmpty else {
            return .internal
        }

        return try Parse(input: Substring.self) {
            Whitespace(.horizontal)
            AccessModifier.parser()
            End()
        }
        .parse(&input)
    }
}
