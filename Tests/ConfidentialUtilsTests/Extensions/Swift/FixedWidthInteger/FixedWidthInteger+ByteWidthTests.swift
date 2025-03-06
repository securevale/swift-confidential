@testable import ConfidentialUtils
import XCTest

final class FixedWidthInteger_ByteWidthTests: XCTestCase {

    func test_givenFixedWidthIntegerTypes_whenByteWidth_thenReturnsExpectedValues() {
        // given
        let types: [Any] = [
            UInt8.self, UInt16.self, UInt32.self, UInt64.self,
            Int8.self, Int16.self, Int32.self, Int64.self
        ]

        // when
        let byteWidths = types.map { ($0 as! any FixedWidthInteger.Type).byteWidth }

        // then
        XCTAssertEqual(
            [
                1, 2, 4, 8,
                1, 2, 4, 8
            ],
            byteWidths
        )
    }
}
