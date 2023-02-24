import Foundation

public extension Obfuscation.Compression {

    /// An algorithm that indicates how to compress or decompress data.
    typealias CompressionAlgorithm = NSData.CompressionAlgorithm
}

public extension Obfuscation.Compression.CompressionAlgorithm {

    /// The number of bytes in the header magic number.
    var headerMagicByteCount: Int {
        switch self {
        case .lzfse, .lz4:
            return 4
        case .lzma:
            return 6
        case .zlib:
            /*
             Apple's zlib implementation uses raw DEFLATE format
             as described in IETF RFC 1951.
             */
            return 0
        @unknown default:
            return 0
        }
    }

    /// The number of bytes in the footer magic number.
    var footerMagicByteCount: Int {
        switch self {
        case .lzfse, .lz4:
            return 4
        case .lzma:
            return 2
        case .zlib:
            return 0
        @unknown default:
            return 0
        }
    }
}
