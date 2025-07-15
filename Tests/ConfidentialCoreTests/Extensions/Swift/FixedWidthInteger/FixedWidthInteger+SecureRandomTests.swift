@testable import ConfidentialCore
import XCTest

final class FixedWidthInteger_SecureRandomTests: XCTestCase {

    func test_givenFixedWidthIntegerTypes_whenSecureRandom_thenConsecutiveValuesAreNotEqual() throws {
        // given
        let types: [any FixedWidthInteger.Type] = [
            UInt8.self, UInt16.self, UInt32.self, UInt64.self,
            Int8.self, Int16.self, Int32.self, Int64.self
        ]

        // when
        let values: [(AnyHashable, AnyHashable)] = try types.map {
            (
                AnyHashable(try $0.secureRandom()),
                AnyHashable(try $0.secureRandom())
            )
        }

        // then
        values.forEach {
            XCTAssertNotEqual($0.0, $0.1)
        }
    }

    func test_givenSecureRandomNumberSource_whenSecureRandom_thenReturnsExpectedValue() throws {
        // given
        let source: FixedWidthInteger.SecureRandomNumberSource = { bytes in
            (0..<bytes.count).forEach { bytes[$0] = 1 }
            return errSecSuccess
        }

        // when
        let value = try Int32.secureRandom(using: source)

        // then
        XCTAssertEqual(Int32(bitPattern: 16843009), value)
    }

    func test_givenUnimplementedSecureRandomNumberSource_whenSecureRandom_thenThrowsExpectedError() {
        // given
        let status: OSStatus = errSecUnimplemented
        let source: FixedWidthInteger.SecureRandomNumberSource = { _ in status }

        // when & then
        XCTAssertThrowsError(try Int32.secureRandom(using: source)) {
            let error = $0 as NSError
            XCTAssertEqual(NSOSStatusErrorDomain, error.domain)
            XCTAssertEqual(.init(status), error.code)
            XCTAssertFalse(error.description.isEmpty)
        }
    }
}
