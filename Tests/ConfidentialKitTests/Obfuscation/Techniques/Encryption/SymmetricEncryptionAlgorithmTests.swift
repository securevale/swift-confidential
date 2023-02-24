@testable import ConfidentialKit
import XCTest

final class SymmetricEncryptionAlgorithmTests: XCTestCase {

    private typealias Algorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm

    func test_whenKeySizeBitCount_thenReturnsExpectedNumberOfBits() {
        XCTAssertEqual(128, Algorithm.aes128GCM.keySize.bitCount)
        XCTAssertEqual(192, Algorithm.aes192GCM.keySize.bitCount)
        XCTAssertEqual(256, Algorithm.aes256GCM.keySize.bitCount)
        XCTAssertEqual(256, Algorithm.chaChaPoly.keySize.bitCount)
    }
}
