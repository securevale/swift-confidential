@testable import ConfidentialKit
import XCTest

final class Obfuscation_SecretTests: XCTestCase {

    private typealias SUT = Obfuscation.Secret

    func test_givenSecretWithTestBytes_whenData_thenReturnsTestBytes() {
        // given
        let testBytes: [UInt8] = [0x35, 0x9d, 0x82, 0x1f, 0x68, 0x81, 0x02, 0x64]
        let sut = SUT(data: testBytes, nonce: .zero)

        // when
        let data = sut.data

        // then
        XCTAssertEqual(testBytes, data)
    }

    func test_givenSecretWithEmptyByteArray_whenData_thenReturnsEmptyArray() {
        // given
        let sut = SUT(data: [], nonce: .zero)

        // when
        let data = sut.data

        // then
        XCTAssertTrue(data.isEmpty)
    }

    func test_givenSecretWithTestNonce_whenNonce_thenReturnsTestNonce() {
        // given
        let testNonce: Obfuscation.Nonce = .StubFactory.makeNonce()
        let sut = SUT(data: [], nonce: testNonce)

        // when
        let nonce = sut.nonce

        // then
        XCTAssertEqual(testNonce, nonce)
    }
}
