import ConfidentialCore
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
        let nonceBytes = nonce.bytes
        let nonceByteWidth = nonceBytes.count
        let obfuscatedBytes = magicBytes.enumerated().map { index, byte in
            byte ^ nonceBytes[index % nonceByteWidth]
        }

        return .init(obfuscatedBytes)
    }
}
