@testable import ConfidentialKit
import XCTest

final class BinaryInteger_BytesTests: XCTestCase {

    func test_givenBinaryIntegers_whenBytes_thenReturnsExpectedValues() {
        // given
        let integers: [Any] = [
            UInt8(1), UInt16(1), UInt32(1), UInt64(1),
            Int8(1), Int16(1), Int32(1), Int64(1)
        ]

        // when
        let bytes = integers.map { ($0 as! any FixedWidthInteger).littleEndian.bytes }

        // then
        XCTAssertEqual(
            [
                [0x01], [0x01, 0x00], [0x01, 0x00, 0x00, 0x00], [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
                [0x01], [0x01, 0x00], [0x01, 0x00, 0x00, 0x00], [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
            ],
            bytes
        )
    }

    func test_givenCollectionOfTwoBytes_whenUInt8InitBytes_thenReturnsUInt8WithExpectedValue() {
        // given
        let bytes: [UInt8] = [0x01, 0x01]

        // when
        let uInt8 = UInt8(bytes: bytes)

        // then
        XCTAssertEqual(1, uInt8)
    }

    func test_givenCollectionOfTwoBytes_whenUInt32InitBytes_thenReturnsUInt32WithExpectedValue() {
        // given
        let bytes: [UInt8] = [0x01, 0x01]

        // when
        let uInt32 = UInt32(bytes: bytes)

        // then
        XCTAssertEqual(257, uInt32)
    }

    func test_givenEmptyCollection_whenIntInitBytes_thenReturnsIntWithValueEqualToZero() {
        // given
        let bytes: [UInt8] = []

        // when
        let int = Int(bytes: bytes)

        // then
        XCTAssertEqual(.zero, int)
    }
}
