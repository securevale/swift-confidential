import ConfidentialCore
import SwiftSyntax

extension Obfuscation.AlgorithmSpecifier {

    var identifier: TokenSyntax {
        let text = switch self {
        case .custom: "custom"
        case .random: "random"
        }

        return .identifier(text)
    }
}
