@testable import ConfidentialKit
import XCTest

import CryptoKit

final class DataCrypterTests: XCTestCase {

    private typealias Algorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm
    private typealias DataCrypter = Obfuscation.Encryption.DataCrypter

    private let plainData: Data = SingleValue.StubFactory.makeSecretMessageData()
    private let encryptionAlgorithms: [Algorithm] = [
        .aes128GCM, .aes192GCM, .aes256GCM, .chaChaPoly
    ]

    func test_givenEncryptedData_whenDeobfuscate_thenReturnsDecryptedData() throws {
        // given
        let encryptedData = encryptionAlgorithms
            .map(makeEncryptedData(using:))

        // when
        let decryptedData = try encryptedData
            .map { algorithm, data in
                try DataCrypter(algorithm: algorithm).deobfuscate(data)
            }

        // then
        decryptedData.forEach { XCTAssertEqual(plainData, $0) }
    }
}

extension DataCrypterTests {

    private func makeEncryptedData(using algorithm: Algorithm) -> (Algorithm, Data) {
        let key = SymmetricKey(size: algorithm.keySize)

        var encryptedData: Data
        switch algorithm {
        case .aes128GCM, .aes192GCM, .aes256GCM:
            encryptedData = try! AES.GCM.seal(plainData, using: key, nonce: .init()).combined!
        case .chaChaPoly:
            encryptedData = try! ChaChaPoly.seal(plainData, using: key, nonce: .init()).combined
        }

        let keyData = key.withUnsafeBytes(Data.init(_:))
        encryptedData.append(keyData)

        return (algorithm, encryptedData)
    }
}
