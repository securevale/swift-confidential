import Parsing
import SwiftSyntax

package struct SourceFileParser<CodeBlockParsers: Parser>: Parser
where
    CodeBlockParsers.Input == SourceFileSpec,
    CodeBlockParsers.Output == [CodeBlockItemSyntax]
{ // swiftlint:disable:this opening_brace

    private let codeBlockParsers: CodeBlockParsers

    init(@ParserBuilder<SourceFileSpec> with build: () -> CodeBlockParsers) {
        self.codeBlockParsers = build()
    }

    package func parse(_ input: inout SourceFileSpec) throws -> SourceFileText {
        let statements = try codeBlockParsers.parse(&input)

        return .init(
            from: SourceFileSyntax(
                statements: CodeBlockItemListSyntax(statements)
            )
        )
    }
}

package extension Parsers.CodeGeneration {

    typealias SourceFile = SourceFileParser
}
