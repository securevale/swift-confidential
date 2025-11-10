import Foundation
import Parsing
import SwiftSyntax
import class Yams.YAMLDecoder

package struct ConfidentialParser<SourceFileSpecParser: Parser, SourceFileParser: Parser>: Parser
where
    SourceFileSpecParser.Input == Configuration,
    SourceFileSpecParser.Output == SourceFileSpec,
    SourceFileParser.Input == SourceFileSpec,
    SourceFileParser.Output == SourceFileSyntax
{ // swiftlint:disable:this opening_brace

    private let configurationDecoder: any DataDecoder
    private let sourceFileSpecParser: SourceFileSpecParser
    private let sourceFileParser: SourceFileParser

    init(
        configurationDecoder: any DataDecoder,
        sourceFileSpecParser: SourceFileSpecParser,
        sourceFileParser: SourceFileParser
    ) {
        self.configurationDecoder = configurationDecoder
        self.sourceFileSpecParser = sourceFileSpecParser
        self.sourceFileParser = sourceFileParser
    }

    package func parse(_ input: inout Data) throws -> SourceFileText {
        let configuration = try configurationDecoder.decode(
            Configuration.self,
            from: input
        )

        let sourceFileSpec = try sourceFileSpecParser
            .parse(configuration)
        let sourceFileSyntax = try sourceFileParser
            .parse(sourceFileSpec)

        input.removeAll()

        return .init(from: sourceFileSyntax)
    }
}
