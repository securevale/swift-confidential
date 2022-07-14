import Parsing
import SwiftSyntaxBuilder

public struct ExpressibleAsCodeBlockItemFlatMap<P: Parser>: Parser
where
P.Input == SourceSpecification,
P.Output == [ExpressibleAsCodeBlockItem]
{

    private let parsers: [P]

    init(_ parsers: [P]) {
        self.parsers = parsers
    }

    public func parse(_ input: inout SourceSpecification) throws -> [ExpressibleAsCodeBlockItem] {
        try parsers.flatMap { parser in
            try parser.parse(&input)
        }
    }
}

extension ParserBuilder {

    static func buildBlock<P>(_ parsers: P...) -> ExpressibleAsCodeBlockItemFlatMap<P> {
        .init(parsers)
    }
}

extension OneOfBuilder {

    static func buildBlock<P>(_ parsers: P...) -> Parsers.OneOfMany<P>
    where
    P.Input == Substring,
    P.Output == SourceSpecification.ObfuscationStep.Technique {
        .init(parsers)
    }
}
