import SwiftSyntax
import SwiftSyntaxBuilder

struct InlineAlwaysAttribute: SyntaxBuildable {

    private let leadingTrivia: Trivia?

    init(leadingTrivia: Trivia? = .none) {
        self.leadingTrivia = leadingTrivia
    }

    func buildSyntax(format: Format, leadingTrivia: Trivia?) -> Syntax {
        makeUnderlyingSyntax().buildSyntax(format: format, leadingTrivia: leadingTrivia)
    }
}

private extension InlineAlwaysAttribute {

    func makeUnderlyingSyntax() -> SyntaxBuildable {
        Attribute(
            atSignToken: .atSign.withLeadingTrivia(leadingTrivia ?? .zero),
            attributeName: .identifier("inline"),
            leftParen: .leftParen,
            argument: IdentifierExpr("__always"),
            rightParen: .rightParen,
            tokenList: .none
        )
    }
}
