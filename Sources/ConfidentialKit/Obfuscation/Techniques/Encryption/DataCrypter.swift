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
        @inlinable
        @inline(__always)
        public init(algorithm: SymmetricEncryptionAlgorithm) {
            self.algorithm = algorithm
        }

        /// Decrypts the given data using preset ``algorithm``.
        ///
        /// - Parameter data: An encrypted input data.
        /// - Parameter nonce: Reserved for future use.
        /// - Returns: A decrypted output data.
        @inlinable
        @inline(__always)
        public func deobfuscate(_ data: Data, nonce: Obfuscation.Nonce) throws -> Data {
            var obfuscatedData = data
            let keyData = obfuscatedData.suffix(algorithm.keySize.byteCount)
            obfuscatedData.removeLast(algorithm.keySize.byteCount)

            let deobfuscatedData: Data
            switch algorithm {
            case .aes128GCM, .aes192GCM, .aes256GCM:
                let sealedBox = try AES.GCM.SealedBox(combined: obfuscatedData)
                deobfuscatedData = try AES.GCM.open(sealedBox, using: .init(data: keyData))
            case .chaChaPoly:
                let sealedBox = try ChaChaPoly.SealedBox(combined: obfuscatedData)
                deobfuscatedData = try ChaChaPoly.open(sealedBox, using: .init(data: keyData))
            }

            return deobfuscatedData
        }
    }
}
