import Parsing
import SwiftSyntax

struct SourceFileParser<CodeBlockParsers: Parser>: Parser
where
    CodeBlockParsers.Input == SourceFileSpec,
    CodeBlockParsers.Output == [CodeBlockItemSyntax]
{ // swiftlint:disable:this opening_brace

    private let codeBlockParsers: CodeBlockParsers

    init(@ParserBuilder<SourceFileSpec> with build: () -> CodeBlockParsers) {
        self.codeBlockParsers = build()
    }

    func parse(_ input: inout SourceFileSpec) throws -> SourceFileSyntax {
        let statements = try codeBlockParsers.parse(&input)

        return .init(
            statements: CodeBlockItemListSyntax(statements)
        )
    }
}
