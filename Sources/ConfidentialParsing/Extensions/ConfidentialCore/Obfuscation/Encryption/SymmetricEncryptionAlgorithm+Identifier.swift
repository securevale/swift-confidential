import ConfidentialCore
import SwiftSyntax

extension Obfuscation.Encryption.SymmetricEncryptionAlgorithm {

    var identifier: TokenSyntax { .identifier(rawValue) }
}
