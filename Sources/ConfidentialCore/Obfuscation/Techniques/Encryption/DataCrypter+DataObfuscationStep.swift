import ConfidentialKit
import CryptoKit
import Foundation

extension Obfuscation.Encryption.DataCrypter: DataObfuscationStep {

    func obfuscate(_ data: Data, nonce: Obfuscation.Nonce) throws -> Data {
        let key = SymmetricKey(size: algorithm.keySize)

        var obfuscatedData = try encryptData(data, using: key)

        let obfuscatedKeyData = obfuscateKeyData(
            key.withUnsafeBytes(Data.init(_:)),
            nonce: nonce
        )
        let magicBit: UInt64 = 1 << 7
        if nonce & magicBit == 0 {
            obfuscatedData.insert(contentsOf: obfuscatedKeyData, at: 0)
        } else {
            obfuscatedData.append(contentsOf: obfuscatedKeyData)
        }

        return obfuscatedData
    }
}

private extension Obfuscation.Encryption.DataCrypter {

    @inline(__always)
    func encryptData(_ data: Data, using key: SymmetricKey) throws -> Data {
        switch algorithm {
        case .aes128GCM, .aes192GCM, .aes256GCM:
            let sealedBox = try AES.GCM.seal(data, using: key, nonce: .init())
            /*
             As the official documentation states, when we use the nonce of the
             default size of 12 bytes, the combined representation is available,
             hence the use of force unwrap.
             See https://developer.apple.com/documentation/cryptokit/aes/gcm/sealedbox
             for more details.
             */
            return sealedBox.combined! // swiftlint:disable:this force_unwrapping
        case .chaChaPoly:
            let sealedBox = try ChaChaPoly.seal(data, using: key, nonce: .init())
            return sealedBox.combined
        }
    }

    @inline(__always)
    func obfuscateKeyData(_ keyData: Data, nonce: Obfuscation.Nonce) -> Data {
        let nonceByteWidth = Obfuscation.Nonce.byteWidth
        let keyDataChunks = stride(from: .zero, to: keyData.count, by: nonceByteWidth)
            .map { offset -> ArraySlice in
                let startIndex = keyData.startIndex + offset
                let endIndex = min(startIndex + nonceByteWidth, keyData.endIndex)
                return .init(keyData[startIndex..<endIndex])
            }

        let obfuscatedKeyBytes = keyDataChunks
            .map {
                $0.withUnsafeBytes { $0.load(as: Obfuscation.Nonce.self) } ^ nonce
            }
            .flatMap(\.bytes)

        return .init(obfuscatedKeyBytes)
    }
}
