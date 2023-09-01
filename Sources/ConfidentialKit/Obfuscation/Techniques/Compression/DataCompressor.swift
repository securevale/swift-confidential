import Foundation

public extension Obfuscation.Compression {

    /// An implementation of obfuscation technique utilizing data compression.
    ///
    /// See ``CompressionAlgorithm`` for a list of supported compression algorithms.
    struct DataCompressor: DataDeobfuscationStep {

        /// An algorithm used to compress and decompress the data.
        public let algorithm: CompressionAlgorithm

        /// Creates a new instance with the specified compression algorithm.
        ///
        /// - Parameter algorithm: An algorithm used to compress and decompress the data.
        public init(algorithm: CompressionAlgorithm) {
            self.algorithm = algorithm
        }

        /// Decompresses the given data using preset ``algorithm``.
        ///
        /// - Parameter data: A compressed input data.
        /// - Parameter nonce: A nonce used to deobfuscate the magic numbers identifying the
        ///                    compression algorithm.
        /// - Returns: A decompressed output data.
        @inlinable
        @inline(__always)
        public func deobfuscate(_ data: Data, nonce: Obfuscation.Nonce) throws -> Data {
            var obfuscatedData = data

            if algorithm.headerMagicByteCount > .zero {
                let magicByteCount = algorithm.headerMagicByteCount
                let obfuscatedMagicBytes = obfuscatedData.prefix(magicByteCount)
                let magicBytes = Internal.deobfuscateMagicBytes(
                    obfuscatedMagicBytes,
                    nonce: nonce
                )
                obfuscatedData.replaceSubrange(..<magicByteCount, with: magicBytes)
            }
            if algorithm.footerMagicByteCount > .zero {
                let magicByteCount = algorithm.footerMagicByteCount
                let obfuscatedMagicBytes = obfuscatedData.suffix(magicByteCount)
                let magicBytes = Internal.deobfuscateMagicBytes(
                    obfuscatedMagicBytes,
                    nonce: nonce.byteSwapped
                )
                let endIndex = obfuscatedData.endIndex
                let startIndex = obfuscatedData.index(endIndex, offsetBy: -magicByteCount)
                obfuscatedData.replaceSubrange(startIndex..<endIndex, with: magicBytes)
            }
            let deobfuscatedData = try NSData(data: obfuscatedData).decompressed(using: algorithm)

            return .init(referencing: deobfuscatedData)
        }
    }
}

extension Obfuscation.Compression.DataCompressor {

    @usableFromInline
    enum Internal {

        @usableFromInline
        @inline(__always)
        static func deobfuscateMagicBytes<Bytes: Collection>(
            _ magicBytes: Bytes,
            nonce: Obfuscation.Nonce
        ) -> Data where Bytes.Element == UInt8, Bytes.Index == Int {
            let nonceBytes = nonce.bytes
            let nonceByteWidth = nonceBytes.count
            let deobfuscatedBytes = magicBytes.enumerated().map { index, byte in
                byte ^ nonceBytes[index % nonceByteWidth]
            }

            return .init(deobfuscatedBytes)
        }
    }
}
