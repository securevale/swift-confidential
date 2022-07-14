@testable import ConfidentialCore
import XCTest

import SwiftSyntax

final class TokenSyntax_TokensTests: XCTestCase {

    func testAtSign() {
        XCTAssertEqual(
            "@",
            .init(
                describing: TokenSyntax.atSign(
                    leadingNewlines: .zero,
                    followedByLeadingSpaces: .zero
                )
            )
        )
        XCTAssertEqual(
            """

              @
            """,
            .init(
                describing: TokenSyntax.atSign(
                    leadingNewlines: 1,
                    followedByLeadingSpaces: 2
                )
            )
        )
        XCTAssertEqual(
            """


                @
            """,
            .init(
                describing: TokenSyntax.atSign(
                    leadingNewlines: 2,
                    followedByLeadingSpaces: 4
                )
            )
        )
    }

    func testPeriod() {
        XCTAssertEqual(
            ".",
            .init(
                describing: TokenSyntax.period(
                    leadingNewlines: .zero,
                    followedByLeadingSpaces: .zero
                )
            )
        )
        XCTAssertEqual(
            """

              .
            """,
            .init(
                describing: TokenSyntax.period(
                    leadingNewlines: 1,
                    followedByLeadingSpaces: 2
                )
            )
        )
        XCTAssertEqual(
            """


                .
            """,
            .init(
                describing: TokenSyntax.period(
                    leadingNewlines: 2,
                    followedByLeadingSpaces: 4
                )
            )
        )
    }

    func testRightParen() {
        XCTAssertEqual(
            ")",
            .init(
                describing: TokenSyntax.rightParen(
                    leadingNewlines: .zero,
                    followedByLeadingSpaces: .zero
                )
            )
        )
        XCTAssertEqual(
            """

              )
            """,
            .init(
                describing: TokenSyntax.rightParen(
                    leadingNewlines: 1,
                    followedByLeadingSpaces: 2
                )
            )
        )
        XCTAssertEqual(
            """


                )
            """,
            .init(
                describing: TokenSyntax.rightParen(
                    leadingNewlines: 2,
                    followedByLeadingSpaces: 4
                )
            )
        )
    }

    func testPrivate() {
        XCTAssertEqual(
            "private",
            .init(
                describing: TokenSyntax.private(
                    leadingNewlines: .zero,
                    followedByLeadingSpaces: .zero,
                    trailingSpaces: .zero
                )
            )
        )
        XCTAssertEqual(
            """

              private\u{0020}
            """,
            .init(
                describing: TokenSyntax.private(
                    leadingNewlines: 1,
                    followedByLeadingSpaces: 2,
                    trailingSpaces: 1
                )
            )
        )
        XCTAssertEqual(
            """


                private\u{0020}\u{0020}\u{0020}\u{0020}
            """,
            .init(
                describing: TokenSyntax.private(
                    leadingNewlines: 2,
                    followedByLeadingSpaces: 4,
                    trailingSpaces: 4
                )
            )
        )
    }

    func testStatic() {
        XCTAssertEqual(
            "static",
            .init(
                describing: TokenSyntax.static(
                    leadingNewlines: .zero,
                    followedByLeadingSpaces: .zero,
                    trailingSpaces: .zero
                )
            )
        )
        XCTAssertEqual(
            """

              static\u{0020}
            """,
            .init(
                describing: TokenSyntax.static(
                    leadingNewlines: 1,
                    followedByLeadingSpaces: 2,
                    trailingSpaces: 1
                )
            )
        )
        XCTAssertEqual(
            """


                static\u{0020}\u{0020}\u{0020}\u{0020}
            """,
            .init(
                describing: TokenSyntax.static(
                    leadingNewlines: 2,
                    followedByLeadingSpaces: 4,
                    trailingSpaces: 4
                )
            )
        )
    }
}
