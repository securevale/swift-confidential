import ConfidentialUtils
import CryptoKit
import Foundation

public extension Obfuscation.Encryption {

    /// An implementation of obfuscation technique utilizing data encryption.
    ///
    /// See ``SymmetricEncryptionAlgorithm`` for a list of supported encryption algorithms.
    struct DataCrypter: DataDeobfuscationStep {

        /// An algorithm used to encrypt and decrypt the data.
        public let algorithm: SymmetricEncryptionAlgorithm

        /// Creates a new instance with the specified symmetric encryption algorithm.
        ///
        /// - Parameter algorithm: An algorithm used to encrypt and decrypt the data.
        public init(algorithm: SymmetricEncryptionAlgorithm) {
            self.algorithm = algorithm
        }

        /// Decrypts the given data using preset ``algorithm``.
        ///
        /// - Parameter data: An encrypted input data.
        /// - Parameter nonce: A nonce used to deobfuscate the encryption key data.
        /// - Returns: A decrypted output data.
        @inlinable
        @inline(__always)
        public func deobfuscate(_ data: Data, nonce: Obfuscation.Nonce) throws -> Data {
            var obfuscatedData = data

            let obfuscatedKeyData: Data
            let keySize = algorithm.keySize.byteCount
            let magicBit: UInt64 = 1 << 7
            if nonce & magicBit == 0 {
                obfuscatedKeyData = obfuscatedData.prefix(keySize)
                obfuscatedData.removeFirst(keySize)
            } else {
                obfuscatedKeyData = obfuscatedData.suffix(keySize)
                obfuscatedData.removeLast(keySize)
            }
            let keyData = Internal.deobfuscateKeyData(obfuscatedKeyData, nonce: nonce)

            let deobfuscatedData = try Internal.decryptData(
                obfuscatedData,
                using: .init(data: keyData),
                algorithm: algorithm
            )

            return deobfuscatedData
        }
    }
}

extension Obfuscation.Encryption.DataCrypter {

    @usableFromInline
    enum Internal {

        @usableFromInline
        @inline(__always)
        static func decryptData(
            _ data: Data,
            using key: SymmetricKey,
            algorithm: Obfuscation.Encryption.SymmetricEncryptionAlgorithm
        ) throws -> Data {
            switch algorithm {
            case .aes128GCM, .aes192GCM, .aes256GCM:
                let sealedBox = try AES.GCM.SealedBox(combined: data)
                return try AES.GCM.open(sealedBox, using: key)
            case .chaChaPoly:
                let sealedBox = try ChaChaPoly.SealedBox(combined: data)
                return try ChaChaPoly.open(sealedBox, using: key)
            }
        }

        @usableFromInline
        @inline(__always)
        static func deobfuscateKeyData(_ keyData: Data, nonce: Obfuscation.Nonce) -> Data {
            let nonceBytes = nonce.bytes
            let nonceByteWidth = nonceBytes.count
            let deobfuscatedKeyBytes = keyData.enumerated().map { index, byte in
                byte ^ nonceBytes[index % nonceByteWidth]
            }

            return .init(deobfuscatedKeyBytes)
        }
    }
}
