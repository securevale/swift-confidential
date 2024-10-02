import Foundation
import SwiftSyntax

public struct SourceFileText: Equatable {

    private let syntax: Syntax

    init(from sourceFile: SourceFileSyntax) {
        self.syntax = sourceFile
            .formatted(using: .init(indentationWidth: .spaces(0)))
    }

    public func write(to url: URL, encoding: String.Encoding = .utf8) throws {
        var text = ""
        syntax.write(to: &text)

        try text
            .trimmingCharacters(in: .newlines)
            .write(to: url, atomically: true, encoding: encoding)
    }
}

extension SourceFileText: CustomStringConvertible {

    public var description: String { syntax.description }
}
