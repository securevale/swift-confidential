import SwiftSyntax

enum C {

    enum Code {

        enum Format {
            static let indentWidth: Trivia = .spaces(4)
        }

        enum Generation {
            static let confidentialCoreModuleName: String = "ConfidentialCore"
            static let confidentialKitModuleName: String = "ConfidentialKit"

            static let obfuscateMacroName: String = "Obfuscate"
        }
    }

    enum Parsing {

        enum Keywords {
            static let random: String = "random"
            static let compress: String = "compress"
            static let encrypt: String = "encrypt"
            static let shuffle: String = "shuffle"
            static let using: String = "using"
            static let create: String = "create"
            static let extend: String = "extend"
            static let from: String = "from"
        }
    }
}
