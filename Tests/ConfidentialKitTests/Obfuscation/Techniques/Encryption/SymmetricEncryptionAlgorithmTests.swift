@testable import ConfidentialKit
import XCTest

final class SymmetricEncryptionAlgorithmTests: XCTestCase {

    private typealias SUT = Obfuscation.Encryption.SymmetricEncryptionAlgorithm

    func test_whenKeySizeBitCount_thenReturnsExpectedNumberOfBits() {
        XCTAssertEqual(128, SUT.aes128GCM.keySize.bitCount)
        XCTAssertEqual(192, SUT.aes192GCM.keySize.bitCount)
        XCTAssertEqual(256, SUT.aes256GCM.keySize.bitCount)
        XCTAssertEqual(256, SUT.chaChaPoly.keySize.bitCount)
    }
}
