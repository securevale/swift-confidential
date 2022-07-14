@testable import ConfidentialKit
import XCTest

final class Obfuscation_SecretTests: XCTestCase {

    func test_givenSecretWithTestBytes_whenData_thenReturnsTestBytes() {
        // given
        let testBytes: [UInt8] = [0x35, 0x9d, 0x82, 0x1f, 0x68, 0x81, 0x02, 0x64]
        let secret = Obfuscation.Secret(data: testBytes)

        // when
        let data = secret.data

        // then
        XCTAssertEqual(testBytes, data)
    }

    func test_givenSecretWithEmptyByteArray_whenData_thenReturnsEmptyArray() {
        // given
        let secret = Obfuscation.Secret(data: [])

        // when
        let data = secret.data

        // then
        XCTAssertTrue(data.isEmpty)
    }
}
