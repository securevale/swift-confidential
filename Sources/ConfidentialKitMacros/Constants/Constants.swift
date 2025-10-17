import SwiftSyntax

enum C {

    enum Code {

        enum Format {
            static let indentWidth: Trivia = .spaces(4)
        }

        enum Generation {
            static let obfuscatedMacroFullyQualifiedName: String = "ConfidentialKit.Obfuscated"
        }
    }
}
