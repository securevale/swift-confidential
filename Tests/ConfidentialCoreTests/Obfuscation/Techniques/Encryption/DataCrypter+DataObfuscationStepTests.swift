@testable import ConfidentialCore
import XCTest

import ConfidentialKit

final class DataCrypter_DataObfuscationStepTests: XCTestCase {

    private typealias SUT = Obfuscation.Encryption.DataCrypter

    func test_givenPlainData_whenObfuscate_thenEncryptedDataNotEmptyAndNotEqualToPlainData() throws {
        // given
        let plainData: Data = .init(
            [0x2e, 0xea, 0xf5, 0xef, 0xa5, 0xda, 0x5d, 0xfd, 0x4a, 0x72, 0xd6, 0x97]
        )

        // when
        let encryptedData = try encryptionParamsStub.map { params in
            try SUT(algorithm: params.algorithm)
                .obfuscate(plainData, nonce: params.nonce)
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
        let encryptedData = try encryptionParamsStub.map { params in
            (
                params,
                try SUT(algorithm: params.algorithm)
                    .obfuscate(plainData, nonce: params.nonce)
            )
        }

        // when
        let decryptedData = try encryptedData.map { params, data in
            try SUT(algorithm: params.algorithm)
                .deobfuscate(data, nonce: params.nonce)
        }

        // then
        decryptedData.forEach { XCTAssertEqual(plainData, $0) }
    }
}

private extension DataCrypter_DataObfuscationStepTests {

    typealias Algorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm

    struct EncryptionParams {
        let algorithm: Algorithm
        let nonce: Obfuscation.Nonce
    }

    var encryptionParamsStub: [EncryptionParams] {
        [
            .init(
                algorithm: .aes128GCM,
                nonce: 3683273644876213525 // magic bit OFF
            ),
            .init(
                algorithm: .aes192GCM,
                nonce: 2467393122768582588 // magic bit ON
            ),
            .init(
                algorithm: .aes256GCM,
                nonce: 11699582232143540816 // magic bit OFF
            ),
            .init(
                algorithm: .chaChaPoly,
                nonce: 4110998048993541303 // magic bit ON
            )
        ]
    }
}
