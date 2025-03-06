import CryptoKit

package extension SymmetricKeySize {

    /// The number of bytes in the key.
    ///
    /// The returned value is not rounded up, since ``init(bitCount:)`` only accepts
    /// positive integers that are a multiple of 8.
    @inlinable
    @inline(__always)
    var byteCount: Int { bitCount / 8 }
}
