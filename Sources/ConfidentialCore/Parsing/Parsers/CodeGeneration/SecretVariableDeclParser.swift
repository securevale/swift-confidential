import Parsing
import SwiftSyntax

struct SecretVariableDeclParser: Parser {

    typealias Secret = SourceSpecification.Secret

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
            accessModifier: token(for: input.accessModifier),
            name: input.name,
            dataArgumentExpression: ArrayExprSyntax(elements: .init(dataArgumentElements)),
            nonceArgumentExpression: IntegerLiteralExprSyntax(literal: "\(raw: input.nonce)"),
            dataAccessWrapper: dataAccessWrapper(with: input.dataAccessWrapperInfo)
        )
    }
}

private extension SecretVariableDeclParser {

    func token(for accessModifier: Secret.AccessModifier) -> TokenSyntax {
        switch accessModifier {
        case .internal:
            return .keyword(.internal)
        case .public:
            return .keyword(.public)
        }
    }

    func dataAccessWrapper(with wrapperInfo: Secret.DataAccessWrapperInfo) -> AttributeSyntax {
        .init(
            atSign: .atSignToken(leadingNewlines: 1),
            attributeName: IdentifierTypeSyntax(
                name: .identifier(wrapperInfo.typeInfo.fullyQualifiedName)
            ),
            leftParen: .leftParenToken(),
            arguments: .argumentList(
                .init(
                    wrapperInfo.arguments
                        .map { argument in
                            LabeledExprSyntax(
                                label: argument.label.map { .identifier($0) },
                                colon: argument.label.map { _ in .colonToken() },
                                expression: DeclReferenceExprSyntax(baseName: .identifier(argument.value))
                            )
                        }
                )
            ),
            rightParen: .rightParenToken()
        )
    }
}
