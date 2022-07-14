import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

public struct SourceFileText: Equatable {

    private let syntax: Syntax

    init(from sourceFile: ExpressibleAsSourceFile) {
        self.syntax = sourceFile
            .createSourceFile()
            .buildSyntax(format: .init(indentWidth: .zero))
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
