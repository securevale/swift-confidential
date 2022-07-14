@testable import ConfidentialCore
import XCTest

import ConfidentialKit

final class DataCrypter_DataObfuscationStepTests: XCTestCase {

    private typealias Algorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm
    private typealias DataCrypter = Obfuscation.Encryption.DataCrypter

    private let encryptionAlgorithms: [Algorithm] = [
        .aes128GCM, .aes192GCM, .aes256GCM, .chaChaPoly
    ]

    func test_givenPlainData_whenObfuscate_thenEncryptedDataNotEmptyAndNotEqualToPlainData() throws {
        // given
        let plainData: Data = .init(
            [0x2e, 0xea, 0xf5, 0xef, 0xa5, 0xda, 0x5d, 0xfd, 0x4a, 0x72, 0xd6, 0x97]
        )

        // when
        let encryptedData = try encryptionAlgorithms.map {
            try DataCrypter(algorithm: $0).obfuscate(plainData)
        }

        // then
        encryptedData.forEach {
            XCTAssertFalse($0.isEmpty)
            XCTAssertNotEqual(plainData, $0)
        }
    }

    func test_givenEncryptedDataAfterObfuscateCall_whenDeobfuscate_thenReturnsDecryptedData() throws {
        // given
        let plainData: Data = .init(
            [0xdf, 0xc8, 0x72, 0x04, 0x6b, 0xbf, 0xe5, 0x54, 0x33, 0x0e, 0xc2, 0x4f]
        )
        let encryptedData = try encryptionAlgorithms.map {
            ($0, try DataCrypter(algorithm: $0).obfuscate(plainData))
        }

        // when
        let decryptedData = try encryptedData.map {
            try DataCrypter(algorithm: $0.0).deobfuscate($0.1)
        }

        // then
        decryptedData.forEach { XCTAssertEqual(plainData, $0) }
    }
}
