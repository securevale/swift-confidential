@testable import ConfidentialCore
import XCTest

import SwiftSyntaxBuilder

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
        super.tearDown()
    }

    func test_givenSourceFileTextWithSourceFileSyntax_whenWriteToFile_thenFileContainsExpectedSyntaxText() throws {
        // given
        let sourceFile = SourceFile(eofToken: .eof) {
            ImportDecl(
                path: AccessPath([AccessPathComponent(name: .identifier("Foundation"))])
            )
            StructDecl(
                structKeyword: .struct.withLeadingTrivia(.newlines(1)),
                identifier: "Test",
                members: MemberDeclBlock(
                    leftBrace: .leftBrace.withLeadingTrivia(.spaces(1)),
                    rightBrace: .rightBrace
                ) {
                    VariableDecl(
                        .let.withLeadingTrivia(.spaces(2)),
                        name: IdentifierPattern("id"),
                        type: TypeAnnotation("UUID")
                    )
                    VariableDecl(
                        .var.withLeadingTrivia(.spaces(2)),
                        name: IdentifierPattern("data"),
                        type: TypeAnnotation("Data")
                    )
                }
            )
        }
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
