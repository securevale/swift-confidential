import ConfidentialKit

extension Obfuscation.Compression.CompressionAlgorithm: CaseIterable {

    public static var allCases: [Self] {
        [
            .lzfse,
            .lz4,
            .lzma,
            .zlib
        ]
    }
}
