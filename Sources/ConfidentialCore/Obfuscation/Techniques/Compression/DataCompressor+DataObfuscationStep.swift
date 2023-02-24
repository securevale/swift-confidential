import ConfidentialKit
import Foundation

extension Obfuscation.Compression.DataCompressor: DataObfuscationStep {

    func obfuscate(_ data: Data, nonce: Obfuscation.Nonce) throws -> Data {
        var obfuscatedData = Data(
            referencing: try NSData(data: data).compressed(using: algorithm)
        )

        if algorithm.headerMagicByteCount > .zero {
            let magicByteCount = algorithm.headerMagicByteCount
            let magicBytes = obfuscatedData.prefix(magicByteCount)
            let obfuscatedMagicBytes = obfuscateMagicBytes(
                magicBytes,
                nonce: nonce
            )
            obfuscatedData.replaceSubrange(..<magicByteCount, with: obfuscatedMagicBytes)
        }
        if algorithm.footerMagicByteCount > .zero {
            let magicByteCount = algorithm.footerMagicByteCount
            let magicBytes = obfuscatedData.suffix(magicByteCount)
            let obfuscatedMagicBytes = obfuscateMagicBytes(
                magicBytes,
                nonce: nonce.byteSwapped
            )
            let endIndex = obfuscatedData.endIndex
            let startIndex = obfuscatedData.index(endIndex, offsetBy: -magicByteCount)
            obfuscatedData.replaceSubrange(startIndex..<endIndex, with: obfuscatedMagicBytes)
        }

        return obfuscatedData
    }
}

private extension Obfuscation.Compression.DataCompressor {

    @inline(__always)
    func obfuscateMagicBytes<Bytes: Collection>(
        _ magicBytes: Bytes,
        nonce: Obfuscation.Nonce
    ) -> Data where Bytes.Element == UInt8, Bytes.Index == Int {
        let nonceByteWidth = Obfuscation.Nonce.byteWidth
        let chunkedBytes = stride(from: .zero, to: magicBytes.count, by: nonceByteWidth)
            .map { offset -> ArraySlice in
                let startIndex = magicBytes.startIndex + offset
                let endIndex = min(startIndex + nonceByteWidth, magicBytes.endIndex)
                return .init(magicBytes[startIndex..<endIndex])
            }

        let obfuscatedBytes = chunkedBytes
            .map { .init(bytes: $0) ^ nonce }
            .flatMap(\.bytes)
            .prefix(magicBytes.count)

        return .init(obfuscatedBytes)
    }
}
