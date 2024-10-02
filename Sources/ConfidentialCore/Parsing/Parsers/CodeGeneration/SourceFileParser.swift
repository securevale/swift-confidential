import Parsing
import SwiftSyntax

public struct SourceFileParser<CodeBlockParsers: Parser>: Parser
where
    CodeBlockParsers.Input == SourceSpecification,
    CodeBlockParsers.Output == [CodeBlockItemSyntax]
{ // swiftlint:disable:this opening_brace

    private let codeBlockParsers: CodeBlockParsers

    init(@ParserBuilder<SourceSpecification> with build: () -> CodeBlockParsers) {
        self.codeBlockParsers = build()
    }

    public func parse(_ input: inout SourceSpecification) throws -> SourceFileText {
        let statements = try codeBlockParsers.parse(&input)

        return .init(
            from: SourceFileSyntax(
                statements: CodeBlockItemListSyntax(statements)
            )
        )
    }
}

public extension Parsers.CodeGeneration {

    typealias SourceFile = SourceFileParser
}
