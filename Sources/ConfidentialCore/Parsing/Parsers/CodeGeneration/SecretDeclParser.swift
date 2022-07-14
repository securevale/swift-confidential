import Parsing
import SwiftSyntaxBuilder

struct SecretDeclParser: Parser {

    typealias Secret = SourceSpecification.Secret

    func parse(_ input: inout Secret) throws -> ExpressibleAsSecretDecl {
        let valueHexComponents = input.data.hexEncodedStringComponents(options: .numericLiteral)
        let dataArgumentElements = valueHexComponents
            .enumerated()
            .map { idx, component in
                ArrayElement(
                    expression: IntegerLiteralExpr(digits: component),
                    trailingComma: idx < valueHexComponents.endIndex - 1 ? .comma : .none
                )
            }

        return SecretDecl(
            name: input.name,
            dataArgumentExpression: ArrayExpr(elements: ArrayElementList(dataArgumentElements)),
            dataAccessWrapper: dataAccessWrapper(with: input.dataAccessWrapperInfo)
        )
    }
}

private extension SecretDeclParser {

    func dataAccessWrapper(with wrapperInfo: Secret.DataAccessWrapperInfo) -> ExpressibleAsCustomAttribute {
        CustomAttribute(
            atSignToken: .atSign(leadingNewlines: 1),
            attributeName: SimpleTypeIdentifier(wrapperInfo.typeInfo.fullyQualifiedName),
            leftParen: .leftParen,
            argumentList: TupleExprElementList(
                wrapperInfo.arguments
                    .map { argument in
                        TupleExprElement(
                            label: argument.label.map { .identifier($0) },
                            colon: argument.label.map { _ in .colon },
                            expression: IdentifierExpr(argument.value)
                        )
                    }
            ),
            rightParen: .rightParen
        )
    }
}
