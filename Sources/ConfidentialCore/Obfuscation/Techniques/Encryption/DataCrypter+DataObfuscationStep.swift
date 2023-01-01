import ConfidentialKit
import CryptoKit
import Foundation

extension Obfuscation.Encryption.DataCrypter: DataObfuscationStep {

    func obfuscate(_ data: Data, nonce: Obfuscation.Nonce) throws -> Data {
        let key = SymmetricKey(size: algorithm.keySize)

        var obfuscatedData: Data
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
            obfuscatedData = sealedBox.combined! // swiftlint:disable:this force_unwrapping
        case .chaChaPoly:
            let sealedBox = try ChaChaPoly.seal(data, using: key, nonce: .init())
            obfuscatedData = sealedBox.combined
        }

        let keyData = key.withUnsafeBytes(Data.init(_:))
        obfuscatedData.append(keyData)

        return obfuscatedData
    }
}
