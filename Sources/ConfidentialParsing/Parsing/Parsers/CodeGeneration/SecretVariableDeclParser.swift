import Parsing
import SwiftSyntax
import SwiftSyntaxBuilder

struct SecretVariableDeclParser: Parser {

    typealias Secret = SourceFileSpec.Secret

    func parse(_ input: inout Secret) throws -> VariableDeclSyntax {
        let valueExpression = switch input.value {
        case let .string(value):
            ExprSyntax(
                StringLiteralExprSyntax(content: value)
            )
        case let .stringArray(value):
            ExprSyntax(
                ArrayExprSyntax(
                    value,
                    transformingElementsWith: { StringLiteralExprSyntax(content: $0) }
                )
            )
        }

        return variableDecl(
            with: input.name,
            valueExpression: valueExpression
        )
    }
}

private extension SecretVariableDeclParser {

    func variableDecl(
        with name: String,
        valueExpression: some ExprSyntaxProtocol
    ) -> VariableDeclSyntax {
        .init(
            leadingTrivia: [.newlines(1)],
            .let,
            name: PatternSyntax(IdentifierPatternSyntax(identifier: .identifier(name))),
            initializer: InitializerClauseSyntax(
                value: valueExpression
            )
        )
    }
}
