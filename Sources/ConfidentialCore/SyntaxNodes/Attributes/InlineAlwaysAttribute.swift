import SwiftSyntax

extension AttributeSyntax {

    static var inlineAlways: Self {
        .init(
            attributeName: IdentifierTypeSyntax(name: .identifier("inline")),
            leftParen: .leftParenToken(),
            arguments: .argumentList(
                [
                    LabeledExprSyntax(
                        expression: TypeExprSyntax(
                            type: IdentifierTypeSyntax(name: .identifier("__always"))
                        )
                    )
                ]
            ),
            rightParen: .rightParenToken()
        )
    }
}
