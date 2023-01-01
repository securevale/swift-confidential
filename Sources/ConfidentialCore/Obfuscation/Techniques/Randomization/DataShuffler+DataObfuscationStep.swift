import ConfidentialKit
import Foundation

extension Obfuscation.Randomization.DataShuffler: DataObfuscationStep {

    func obfuscate(_ data: Data, nonce: Obfuscation.Nonce) throws -> Data {
        let shuffledIndexes: [Int] = (0..<data.count).shuffled()

        var shuffledBytes = reorderBytes(.init(data), given: shuffledIndexes)

        let obfuscatedCount = withUnsafeBytes(of: shuffledBytes.count ^ .init(bytes: nonce.bytes), [UInt8].init)
        shuffledBytes.insert(contentsOf: obfuscatedCount, at: .zero)

        let obfuscatedIndexes = obfuscateIndexes(shuffledIndexes, nonce: nonce)
        shuffledBytes.append(obfuscatedIndexes.byteWidth)
        shuffledBytes.append(contentsOf: obfuscatedIndexes.bytes)

        return .init(shuffledBytes)
    }
}

private extension Obfuscation.Randomization.DataShuffler {

    @inline(__always)
    func reorderBytes(_ bytes: [UInt8], given indexes: [Int]) -> [UInt8] {
        var result: [UInt8] = .init(repeating: .zero, count: bytes.count)
        indexes.enumerated().forEach { oldIdx, newIdx in
            result[newIdx] = bytes[oldIdx]
        }

        return result
    }

    @inline(__always)
    func obfuscateIndexes(
        _ indexes: [Int],
        nonce: Obfuscation.Nonce
    ) -> (bytes: [UInt8], byteWidth: UInt8) {
        let highestIndex = indexes.count - 1
        switch highestIndex {
        case _ where highestIndex <= UInt8.max:
            return (
                bytes: obfuscateIndexes(indexes, indexTransform: UInt8.init, nonce: nonce),
                byteWidth: .init(UInt8.byteWidth)
            )
        case _ where highestIndex <= UInt16.max:
            return (
                bytes: obfuscateIndexes(indexes, indexTransform: UInt16.init, nonce: nonce),
                byteWidth: .init(UInt16.byteWidth)
            )
        default:
            return (
                bytes: obfuscateIndexes(indexes, indexTransform: { $0 }, nonce: nonce),
                byteWidth: .init(Int.byteWidth)
            )
        }
    }

    @inline(__always)
    func obfuscateIndexes<I: BinaryInteger>(
        _ indexes: [Int],
        indexTransform: (Int) -> I,
        nonce: Obfuscation.Nonce
    ) -> [UInt8] {
        indexes
            .map(indexTransform)
            .flatMap { withUnsafeBytes(of: $0 ^ .init(bytes: nonce.bytes), [UInt8].init) }
    }
}
