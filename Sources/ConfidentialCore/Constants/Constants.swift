enum C {

    enum Code {

        enum Format {
            static let indentWidth: Int = 4
        }

        enum Generation {
            static let confidentialKitModuleName: String = "ConfidentialKit"
            static let foundationModuleName: String = "Foundation"

            static let obfuscatedMacroFullyQualifiedName: String = "\(confidentialKitModuleName).Obfuscated"

            static let deobfuscateDataFuncName: String = "deobfuscateData"
            static let deobfuscateDataFuncDataParamName: String = "data"
            static let deobfuscateDataFuncNonceParamName: String = "nonce"
        }
    }

    enum Parsing {

        enum Keywords {
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
