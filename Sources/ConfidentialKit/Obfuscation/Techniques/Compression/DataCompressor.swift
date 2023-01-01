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
        @inlinable
        @inline(__always)
        public init(algorithm: CompressionAlgorithm) {
            self.algorithm = algorithm
        }

        /// Decompresses the given data using preset ``algorithm``.
        ///
        /// - Parameter data: A compressed input data.
        /// - Parameter nonce: Reserved for future use.
        /// - Returns: A decompressed output data.
        @inlinable
        @inline(__always)
        public func deobfuscate(_ data: Data, nonce: Obfuscation.Nonce) throws -> Data {
            let decompressedData = try NSData(data: data).decompressed(using: algorithm)
            return .init(referencing: decompressedData)
        }
    }
}
