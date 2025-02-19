import SwiftSyntax

extension AttributeSyntax {

    static var inlineAlways: Self {
        .init(
            attributeName: IdentifierTypeSyntax(name: .identifier("inline")),
            leftParen: .leftParenToken(),
            arguments: .token(.identifier("__always")),
            rightParen: .rightParenToken()
        )
    }
}
