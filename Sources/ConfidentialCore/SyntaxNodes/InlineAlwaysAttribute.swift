import SwiftSyntax

extension AttributeSyntax {

    static var inlineAlways: Self {
        .init(
            attributeName: TypeSyntax(stringLiteral: "inline"),
            leftParen: .leftParenToken(),
            arguments: .token(.identifier("__always")),
            rightParen: .rightParenToken()
        )
    }
}
