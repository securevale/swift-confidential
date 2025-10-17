import ConfidentialCore
import SwiftSyntax

extension Obfuscation.Compression.CompressionAlgorithm {

    var identifier: TokenSyntax {
        let text = switch self {
        case .lzfse: "lzfse"
        case .lz4: "lz4"
        case .lzma: "lzma"
        case .zlib: "zlib"
        @unknown default: "unknown"
        }

        return .identifier(text)
    }
}
