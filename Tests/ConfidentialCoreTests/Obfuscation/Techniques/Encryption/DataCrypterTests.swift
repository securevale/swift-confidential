@testable import ConfidentialCore
import XCTest

import CryptoKit

final class DataCrypterTests: XCTestCase {

    private typealias SUT = Obfuscation.Encryption.DataCrypter

    private let plainData = Data("Secret message 🔐".utf8)

    func test_givenEncryptedData_whenDeobfuscate_thenReturnsDecryptedData() throws {
        // given
        let encryptedData = encryptionComponentsStub
            .map(makeEncryptedData(using:))

        // when
        let decryptedData = try encryptedData
            .map { components, data in
                let sut = SUT(algorithm: components.algorithm)
                return try sut.deobfuscate(data, nonce: components.nonce)
            }

        // then
        decryptedData.forEach { XCTAssertEqual(plainData, $0) }
    }
}

private extension DataCrypterTests {

    typealias Algorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm

    struct EncryptionComponents {
        let algorithm: Algorithm
        let nonce: Obfuscation.Nonce
        let isMagicBitSet: Bool
        let keyRawData: [UInt8]
        let obfuscatedKeyRawData: [UInt8]
    }

    var encryptionComponentsStub: [EncryptionComponents] {
        [
            .init(
                algorithm: .aes128GCM,
                nonce: 3683273644876213525,
                isMagicBitSet: false,
                keyRawData: [
                    0xe1, 0xc5, 0xa9, 0x7a, 0xd8, 0x4f, 0x92, 0x66, 0xc4, 0x61, 0xd5, 0xfb,
                    0xf1, 0x80, 0x65, 0xc1
                ],
                obfuscatedKeyRawData: [
                    0xf4, 0x68, 0xce, 0x07, 0x05, 0xd2, 0x8f, 0x55, 0xd1, 0xcc, 0xb2, 0x86,
                    0x2c, 0x1d, 0x78, 0xf2
                ]
            ),
            .init(
                algorithm: .aes192GCM,
                nonce: 2467393122768582588,
                isMagicBitSet: true,
                keyRawData: [
                    0xe1, 0xc5, 0xa9, 0x7a, 0xd8, 0x4f, 0x92, 0x66, 0xc4, 0x61, 0xd5, 0xfb,
                    0xf1, 0x80, 0x65, 0xc1, 0x70, 0x95, 0x7b, 0x3d, 0x43, 0x7a, 0x81, 0x81
                ],
                obfuscatedKeyRawData: [
                    0x5d, 0x32, 0x75, 0x91, 0x20, 0xbf, 0xaf, 0x44, 0x78, 0x96, 0x09, 0x10,
                    0x09, 0x70, 0x58, 0xe3, 0xcc, 0x62, 0xa7, 0xd6, 0xbb, 0x8a, 0xbc, 0xa3
                ]
            ),
            .init(
                algorithm: .aes256GCM,
                nonce: 11699582232143540816,
                isMagicBitSet: false,
                keyRawData: [
                    0xe1, 0xc5, 0xa9, 0x7a, 0xd8, 0x4f, 0x92, 0x66, 0xc4, 0x61, 0xd5, 0xfb,
                    0xf1, 0x80, 0x65, 0xc1, 0x70, 0x95, 0x7b, 0x3d, 0x43, 0x7a, 0x81, 0x81,
                    0xa8, 0xe1, 0x7f, 0x29, 0xfb, 0x45, 0xaa, 0x12
                ],
                obfuscatedKeyRawData: [
                    0xb1, 0xf7, 0xca, 0xed, 0xd5, 0x0b, 0xcf, 0xc4, 0x94, 0x53, 0xb6, 0x6c,
                    0xfc, 0xc4, 0x38, 0x63, 0x20, 0xa7, 0x18, 0xaa, 0x4e, 0x3e, 0xdc, 0x23,
                    0xf8, 0xd3, 0x1c, 0xbe, 0xf6, 0x01, 0xf7, 0xb0
                ]
            ),
            .init(
                algorithm: .chaChaPoly,
                nonce: 4110998048993541303,
                isMagicBitSet: true,
                keyRawData: [
                    0xe1, 0xc5, 0xa9, 0x7a, 0xd8, 0x4f, 0x92, 0x66, 0xc4, 0x61, 0xd5, 0xfb,
                    0xf1, 0x80, 0x65, 0xc1, 0x70, 0x95, 0x7b, 0x3d, 0x43, 0x7a, 0x81, 0x81,
                    0xa8, 0xe1, 0x7f, 0x29, 0xfb, 0x45, 0xaa, 0x12
                ],
                obfuscatedKeyRawData: [
                    0x56, 0xb9, 0x3c, 0xb4, 0x29, 0x7d, 0x9f, 0x5f, 0x73, 0x1d, 0x40, 0x35,
                    0x00, 0xb2, 0x68, 0xf8, 0xc7, 0xe9, 0xee, 0xf3, 0xb2, 0x48, 0x8c, 0xb8,
                    0x1f, 0x9d, 0xea, 0xe7, 0x0a, 0x77, 0xa7, 0x2b
                ]
            )
        ]
    }
}

private extension DataCrypterTests {

    func makeEncryptedData(using components: EncryptionComponents) -> (EncryptionComponents, Data) {
        let key = SymmetricKey(data: components.keyRawData)

        var encryptedData: Data
        switch components.algorithm {
        case .aes128GCM, .aes192GCM, .aes256GCM:
            encryptedData = try! AES.GCM.seal(plainData, using: key).combined!
        case .chaChaPoly:
            encryptedData = try! ChaChaPoly.seal(plainData, using: key).combined
        }

        if components.isMagicBitSet {
            encryptedData.append(contentsOf: components.obfuscatedKeyRawData)
        } else {
            encryptedData.insert(contentsOf: components.obfuscatedKeyRawData, at: .zero)
        }

        return (components, encryptedData)
    }
}
