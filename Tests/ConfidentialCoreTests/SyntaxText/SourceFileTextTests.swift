@testable import ConfidentialCore
import XCTest

import SwiftSyntax

final class SourceFileTextTests: XCTestCase {

    private typealias SUT = SourceFileText

    func test_givenSourceFileTextWithSourceFileSyntax_whenGetText_thenReturnsExpectedSyntaxText() {
        // given
        let sourceFile = SourceFileSyntax(
            statements: CodeBlockItemListSyntax(itemsBuilder: {
                CodeBlockItemSyntax(
                    item: .init(
                        ImportDeclSyntax(
                            path: [ImportPathComponentSyntax(name: .identifier("Foundation"))]
                        )
                    ),
                    trailingTrivia: .newline
                )
                CodeBlockItemSyntax(
                    item: .init(
                        StructDeclSyntax(
                            structKeyword: .keyword(.struct, leadingTrivia: .newlines(1)),
                            name: "Test",
                            memberBlock: .init(
                                leftBrace: .leftBraceToken(leadingTrivia: .spaces(1)),
                                rightBrace: .rightBraceToken()
                            ) {
                                VariableDeclSyntax(
                                    leadingTrivia: .spaces(2),
                                    .let,
                                    name: PatternSyntax(stringLiteral: "id"),
                                    type: TypeAnnotationSyntax(type: TypeSyntax(stringLiteral: "UUID"))
                                )
                                VariableDeclSyntax(
                                    leadingTrivia: .spaces(2),
                                    .var,
                                    name: PatternSyntax(stringLiteral: "data"),
                                    type: TypeAnnotationSyntax(type: TypeSyntax(stringLiteral: "Data"))
                                )
                            }
                        )
                    )
                )
            })
        )
        let sut = SUT(from: sourceFile)

        // when
        let sourceFileText = sut.text()

        // then
        XCTAssertEqual(
            """
            import Foundation

            struct Test {
              let id: UUID
              var data: Data
            }
            """,
            sourceFileText
        )
    }
}
