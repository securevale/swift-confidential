import ConfidentialCore
import SwiftSyntax

extension Obfuscation.Step {

    var identifier: TokenSyntax {
        let text = switch self {
        case .compress: "compress"
        case .encrypt: "encrypt"
        case .shuffle: "shuffle"
        }

        return .identifier(text)
    }
}
