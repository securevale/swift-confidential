@testable import ConfidentialKit
import XCTest

final class SymmetricEncryptionAlgorithmTests: XCTestCase {

    private typealias Algorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm

    func test_whenKeySizeBitCount_thenReturnsExpectedNumberOfBits() {
        XCTAssertEqual(Algorithm.aes128GCM.keySize.bitCount, 128)
        XCTAssertEqual(Algorithm.aes192GCM.keySize.bitCount, 192)
        XCTAssertEqual(Algorithm.aes256GCM.keySize.bitCount, 256)
        XCTAssertEqual(Algorithm.chaChaPoly.keySize.bitCount, 256)
    }
}
