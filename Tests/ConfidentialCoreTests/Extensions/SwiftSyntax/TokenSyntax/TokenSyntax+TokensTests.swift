@testable import ConfidentialCore
import XCTest

import SwiftSyntax

final class TokenSyntax_TokensTests: XCTestCase {

    func testAtSignToken() {
        XCTAssertEqual(
            "@",
            .init(
                describing: TokenSyntax.atSignToken(
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
                describing: TokenSyntax.atSignToken(
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
                describing: TokenSyntax.atSignToken(
                    leadingNewlines: 2,
                    followedByLeadingSpaces: 4
                )
            )
        )
    }

    func testPeriodToken() {
        XCTAssertEqual(
            ".",
            .init(
                describing: TokenSyntax.periodToken(
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
                describing: TokenSyntax.periodToken(
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
                describing: TokenSyntax.periodToken(
                    leadingNewlines: 2,
                    followedByLeadingSpaces: 4
                )
            )
        )
    }

    func testRightParenToken() {
        XCTAssertEqual(
            ")",
            .init(
                describing: TokenSyntax.rightParenToken(
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
                describing: TokenSyntax.rightParenToken(
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
                describing: TokenSyntax.rightParenToken(
                    leadingNewlines: 2,
                    followedByLeadingSpaces: 4
                )
            )
        )
    }
}
