import SwiftSyntax

extension TokenSyntax {

    static func atSignToken(
        leadingNewlines: Int,
        followedByLeadingSpaces leadingSpaces: Int = C.Code.Format.indentWidth
    ) -> Self {
        makeToken(
            .atSignToken(),
            withLeadingNewlines: leadingNewlines,
            followedByLeadingSpaces: leadingSpaces
        )
    }

    static func periodToken(
        leadingNewlines: Int,
        followedByLeadingSpaces leadingSpaces: Int = C.Code.Format.indentWidth
    ) -> Self {
        makeToken(
            .periodToken(),
            withLeadingNewlines: leadingNewlines,
            followedByLeadingSpaces: leadingSpaces
        )
    }

    static func rightParenToken(
        leadingNewlines: Int,
        followedByLeadingSpaces leadingSpaces: Int = C.Code.Format.indentWidth
    ) -> Self {
        makeToken(
            .rightParenToken(),
            withLeadingNewlines: leadingNewlines,
            followedByLeadingSpaces: leadingSpaces
        )
    }
}

private extension TokenSyntax {

    static func makeToken(
        _ token: Self,
        withLeadingNewlines leadingNewlines: Int,
        followedByLeadingSpaces leadingSpaces: Int
    ) -> Self {
        guard leadingNewlines > .zero else {
            return token
        }

        return token.with(
            \.leadingTrivia,
            .newlines(leadingNewlines)
            .appending(Trivia.spaces(leadingSpaces))
        )
    }
}
