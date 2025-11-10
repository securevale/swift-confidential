import Foundation
import SwiftSyntax

package struct SourceFileText {

    private let syntax: Syntax

    init(from sourceFile: SourceFileSyntax) {
        self.syntax = sourceFile
            .formatted(using: .init(indentationWidth: C.Code.Format.indentWidth))
    }

    package func write(to url: URL, encoding: String.Encoding = .utf8) throws {
        try description
            .write(to: url, atomically: true, encoding: encoding)
    }
}

extension SourceFileText: CustomStringConvertible {

    package var description: String {
        syntax
            .description
            .trimmingCharacters(in: .newlines)
    }
}

extension SourceFileText: Equatable {

    package static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.description == rhs.description
    }
}
