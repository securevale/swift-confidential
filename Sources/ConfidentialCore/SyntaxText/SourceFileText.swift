import Foundation
import SwiftSyntax

package struct SourceFileText: Equatable {

    private let syntax: Syntax

    init(from sourceFile: SourceFileSyntax) {
        self.syntax = sourceFile
            .formatted(using: .init(indentationWidth: .spaces(0)))
    }

    package func text() -> String {
        var text = ""
        syntax.write(to: &text)

        return text.trimmingCharacters(in: .newlines)
    }
}

extension SourceFileText: CustomStringConvertible {

    package var description: String { syntax.description }
}
