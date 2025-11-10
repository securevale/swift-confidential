@testable import ConfidentialParsing
import XCTest

import SwiftSyntax

final class SourceFileTextTests: XCTestCase {

    private typealias SUT = SourceFileText

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
            statements: CodeBlockItemListSyntax {
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
                            structKeyword: .keyword(.struct, leadingTrivia: .newline),
                            name: "Test",
                            memberBlock: .init(
                                leftBrace: .leftBraceToken(leadingTrivia: .space),
                                rightBrace: .rightBraceToken()
                            ) {
                                VariableDeclSyntax(
                                    .let,
                                    name: PatternSyntax(stringLiteral: "id"),
                                    type: TypeAnnotationSyntax(type: TypeSyntax(stringLiteral: "UUID"))
                                )
                                VariableDeclSyntax(
                                    .var,
                                    name: PatternSyntax(stringLiteral: "data"),
                                    type: TypeAnnotationSyntax(type: TypeSyntax(stringLiteral: "Data"))
                                )
                            }
                        )
                    )
                )
            }
        )
        let sut = SUT(from: sourceFile)
        let encoding = String.Encoding.utf8

        // when
        try sut.write(to: temporaryFileURL, encoding: encoding)

        // then
        let fileContents = try String(contentsOf: temporaryFileURL, encoding: encoding)
        XCTAssertEqual(
            """
            import Foundation

            struct Test {
            \(C.Code.Format.indentWidth)let id: UUID
            \(C.Code.Format.indentWidth)var data: Data
            }
            """,
            fileContents
        )
    }
}
