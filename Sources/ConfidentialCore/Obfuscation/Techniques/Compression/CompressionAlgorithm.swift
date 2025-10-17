import Foundation

public extension Obfuscation.Compression {

    /// An algorithm that indicates how to compress or decompress data.
    typealias CompressionAlgorithm = NSData.CompressionAlgorithm
}

extension Obfuscation.Compression.CompressionAlgorithm: @retroactive CaseIterable {

    public static var allCases: [Self] {
        [
            .lzfse,
            .lz4,
            .lzma,
            .zlib
        ]
    }
}
