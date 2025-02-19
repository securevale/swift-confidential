import SwiftSyntax

extension ObfuscatedMacro {

    enum C {

        static let genericParameterName: String = "PlainValue"

        enum ExpandedCode {

            enum DeobfuscateDataFunction {

                static var defaultDataArgumentLabel: TokenSyntax { .wildcardToken() }
                static var defaultNonceArgumentLabel: TokenSyntax { .identifier("nonce") }
            }

            enum ProjectionVariable {

                static let allowedModifiers: [TokenKind] = [
                    .keyword(.private),
                    .keyword(.internal),
                    .keyword(.package),
                    .keyword(.public),
                    .keyword(.static)
                ]
            }
        }
    }
}
