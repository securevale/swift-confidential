import Foundation

package extension NSData.CompressionAlgorithm {

    /// The number of bytes in the header magic number.
    @inlinable
    @inline(__always)
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
    @inlinable
    @inline(__always)
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
