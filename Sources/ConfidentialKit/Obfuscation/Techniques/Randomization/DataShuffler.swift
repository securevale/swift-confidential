import Foundation

public extension Obfuscation.Randomization {

    /// An implementation of obfuscation technique utilizing data randomization.
    ///
    /// The ``DataShuffler`` uses a pseudorandom number generator (PRNG) to
    /// shuffle the bytes stored in ``Data`` instance being processed, along with a
    /// ``nonce``, which is used to obfuscate the shuffling parameters.
    ///
    /// > Warning: The current implementation of this technique is best suited for secrets of
    ///         which size does not exceed 256 bytes. For larger secrets, the size of the
    ///         obfuscated data will grow from 2N to 3N, where N is the input data size
    ///         in bytes, or even 5N (32-bit platform) or 9N (64-bit platform) if the size of
    ///         input data is larger than 65 536 bytes.
    struct DataShuffler: DataDeobfuscationStep {

        /// Creates a new instance.
        @inlinable
        @inline(__always)
        public init() {}

        /// Deshuffles the given data.
        ///
        /// - Parameter data: A shuffled input data.
        /// - Parameter nonce: A nonce used to deobfuscate the shuffling parameters.
        /// - Returns: A deshuffled output data.
        @inlinable
        @inline(__always)
        public func deobfuscate(_ data: Data, nonce: Obfuscation.Nonce) throws -> Data {
            let countByteWidth = Int.byteWidth
            let nonceBytes = nonce.bytes
            let count = data
                .prefix(upTo: countByteWidth)
                .withUnsafeBytes { $0.load(as: Int.self) } ^ .init(bytes: nonceBytes)
            let indexByteWidthPos = countByteWidth + count
            let indexByteWidth = data[indexByteWidthPos]
            let indexes = Internal.deobfuscateIndexes(
                bytes: .init(data.suffix(from: indexByteWidthPos + 1)),
                byteWidth: indexByteWidth,
                nonceBytes: nonceBytes
            )
            let shuffledBytes = data.subdata(in: countByteWidth..<indexByteWidthPos)
            let bytes = Internal.reorderBytes(.init(shuffledBytes), given: indexes)

            return .init(bytes)
        }
    }
}

extension Obfuscation.Randomization.DataShuffler {

    @usableFromInline
    enum Internal {

        @usableFromInline
        @inline(__always)
        static func reorderBytes(_ bytes: [UInt8], given indexes: [Int]) -> [UInt8] {
            var result: [UInt8] = .init(repeating: .zero, count: bytes.count)
            indexes.enumerated().forEach { newIdx, oldIdx in
                result[newIdx] = bytes[oldIdx]
            }

            return result
        }

        @usableFromInline
        @inline(__always)
        static func deobfuscateIndexes(bytes: [UInt8], byteWidth: UInt8, nonceBytes: [UInt8]) -> [Int] {
            var bytes = bytes[...]
            let byteWidth = Int(byteWidth)
            switch byteWidth {
            case UInt8.byteWidth:
                return deobfuscateIndexes(bytes: &bytes, indexType: UInt8.self, nonceBytes: nonceBytes)
            case UInt16.byteWidth:
                return deobfuscateIndexes(bytes: &bytes, indexType: UInt16.self, nonceBytes: nonceBytes)
            default:
                return deobfuscateIndexes(bytes: &bytes, indexType: Int.self, nonceBytes: nonceBytes)
            }
        }

        @usableFromInline
        @inline(__always)
        static func deobfuscateIndexes<I: FixedWidthInteger>(
            bytes: inout ArraySlice<UInt8>,
            indexType: I.Type,
            nonceBytes: [UInt8]
        ) -> [Int] {
            let byteWidth = indexType.byteWidth
            var indexes: [Int] = []
            while !bytes.isEmpty {
                let index = Int(
                    bytes
                        .prefix(upTo: bytes.startIndex + byteWidth)
                        .withUnsafeBytes { $0.load(as: indexType) } ^ .init(bytes: nonceBytes)
                )
                indexes.append(index)
                bytes.removeFirst(byteWidth)
            }

            return indexes
        }
    }
}
