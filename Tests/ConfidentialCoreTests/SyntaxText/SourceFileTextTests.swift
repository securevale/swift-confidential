@testable import ConfidentialCore
import XCTest

import SwiftSyntax

final class SourceFileTextTests: XCTestCase {

    private var temporaryFileURL: URL!

    override func setUp() {
        super.setUp()
        temporaryFileURL = .init(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("\(UUID().uuidString).swift")
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: temporaryFileURL)
        temporaryFileURL = nil
        try super.tearDownWithError()
    }

    func test_givenSourceFileTextWithSourceFileSyntax_whenWriteToFile_thenFileContainsExpectedSyntaxText() throws {
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
        let sourceFileText = SourceFileText(from: sourceFile)
        let encoding = String.Encoding.utf8

        // when
        try sourceFileText.write(to: temporaryFileURL, encoding: encoding)

        // then
        let fileContents = try String(contentsOf: temporaryFileURL, encoding: encoding)
        XCTAssertEqual(
            """
            import Foundation

            struct Test {
              let id: UUID
              var data: Data
            }
            """,
            fileContents
        )
    }
}
