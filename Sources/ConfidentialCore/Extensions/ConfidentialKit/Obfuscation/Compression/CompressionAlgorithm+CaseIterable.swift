import ConfidentialKit
import Foundation

extension Obfuscation.Compression.CompressionAlgorithm: Swift.CaseIterable {

    public static var allCases: [Self] {
        [
            .lzfse,
            .lz4,
            .lzma,
            .zlib
        ]
    }
}
