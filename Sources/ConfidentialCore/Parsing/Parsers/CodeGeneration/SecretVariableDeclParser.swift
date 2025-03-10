import Parsing
import SwiftSyntax

struct SecretVariableDeclParser: Parser {

    typealias Secret = SourceFileSpec.Secret

    func parse(_ input: inout Secret) throws -> any DeclSyntaxProtocol {
        let valueHexComponents = input.data.hexEncodedStringComponents(options: .numericLiteral)
        let dataArgumentElements = valueHexComponents
            .enumerated()
            .map { idx, component in
                ArrayElementSyntax(
                    expression: IntegerLiteralExprSyntax(literal: .identifier(component)),
                    trailingComma: idx < valueHexComponents.endIndex - 1 ? .commaToken() : .none
                )
            }

        return VariableDeclSyntax.makeSecretVariableDecl(
            dataProjectionAttribute: attribute(from: input.dataProjectionAttribute),
            accessModifier: keyword(for: input.accessModifier),
            bindingSpecifier: input.dataProjectionAttribute.isPropertyWrapper ? .var : .let,
            name: input.name,
            dataArgumentExpression: ArrayExprSyntax(elements: .init(dataArgumentElements)),
            nonceArgumentExpression: IntegerLiteralExprSyntax(literal: "\(raw: input.nonce)")
        )
    }
}

private extension SecretVariableDeclParser {

    func keyword(for accessModifier: Secret.AccessModifier) -> Keyword {
        switch accessModifier {
        case .internal: .internal
        case .package: .package
        case .public: .public
        }
    }

    func attribute(from attribute: Secret.DataProjectionAttribute) -> AttributeSyntax {
        .init(
            atSign: .atSignToken(leadingNewlines: 1),
            attributeName: IdentifierTypeSyntax(
                name: .identifier(attribute.name)
            ),
            leftParen: .leftParenToken(),
            arguments: .argumentList(
                .init(
                    attribute.arguments
                        .map { argument in
                            LabeledExprSyntax(
                                label: argument.label.map { .identifier($0) },
                                colon: argument.label.map { _ in .colonToken() },
                                expression: DeclReferenceExprSyntax(
                                    baseName: .identifier(argument.value)
                                )
                            )
                        }
                )
            ),
            rightParen: .rightParenToken()
        )
    }
}
