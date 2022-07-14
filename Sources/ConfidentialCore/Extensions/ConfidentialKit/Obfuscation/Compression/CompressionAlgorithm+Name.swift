import ConfidentialKit

extension Obfuscation.Compression.CompressionAlgorithm {

    var name: String {
        switch self {
        case .lzfse:
            return "lzfse"
        case .lz4:
            return "lz4"
        case .lzma:
            return "lzma"
        case .zlib:
            return "zlib"
        @unknown default:
            return "unknown"
        }
    }
}
