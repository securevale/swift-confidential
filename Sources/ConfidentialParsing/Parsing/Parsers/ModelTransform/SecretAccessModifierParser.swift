import Parsing

struct SecretAccessModifierParser: Parser {

    typealias Output = SourceFileSpec.Secret.AccessModifier

    func parse(_ input: inout Substring) throws -> Output {
        guard !input.isEmpty else {
            return .internal
        }

        return try Parse(input: Substring.self) {
            Whitespace(.horizontal)
            Output.parser()
            End()
        }
        .parse(&input)
    }
}
