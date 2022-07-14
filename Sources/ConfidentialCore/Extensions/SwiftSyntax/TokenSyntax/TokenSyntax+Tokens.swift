import SwiftSyntax

extension TokenSyntax {

    static func atSign(
        leadingNewlines: Int,
        followedByLeadingSpaces leadingSpaces: Int = C.Code.Format.indentWidth
    ) -> Self {
        makeToken(
            .atSign.withoutTrivia(),
            withLeadingNewlines: leadingNewlines,
            followedByLeadingSpaces: leadingSpaces
        )
    }

    static func period(
        leadingNewlines: Int,
        followedByLeadingSpaces leadingSpaces: Int = C.Code.Format.indentWidth
    ) -> Self {
        makeToken(
            .period.withoutTrivia(),
            withLeadingNewlines: leadingNewlines,
            followedByLeadingSpaces: leadingSpaces
        )
    }

    static func rightParen(
        leadingNewlines: Int,
        followedByLeadingSpaces leadingSpaces: Int = C.Code.Format.indentWidth
    ) -> Self {
        makeToken(
            .rightParen.withoutTrivia(),
            withLeadingNewlines: leadingNewlines,
            followedByLeadingSpaces: leadingSpaces
        )
    }

    static func `private`(
        leadingNewlines: Int,
        followedByLeadingSpaces leadingSpaces: Int = C.Code.Format.indentWidth,
        trailingSpaces: Int = 1
    ) -> Self {
        makeToken(
            .private.withoutTrivia().withTrailingTrivia(.spaces(trailingSpaces)),
            withLeadingNewlines: leadingNewlines,
            followedByLeadingSpaces: leadingSpaces
        )
    }

    static func `static`(
        leadingNewlines: Int,
        followedByLeadingSpaces leadingSpaces: Int = C.Code.Format.indentWidth,
        trailingSpaces: Int = 1
    ) -> Self {
        makeToken(
            .static.withoutTrivia().withTrailingTrivia(.spaces(trailingSpaces)),
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

        return token.withLeadingTrivia(
            .newlines(leadingNewlines)
            .appending(.spaces(leadingSpaces))
        )
    }
}
