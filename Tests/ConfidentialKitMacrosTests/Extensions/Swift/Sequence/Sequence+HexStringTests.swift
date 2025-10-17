@testable import ConfidentialKitMacros
import XCTest

final class Sequence_HexStringTests: XCTestCase {

    private let bytesStub: [UInt8] = [0xff, 0x36, 0xb4, 0xcb, 0x34, 0xff, 0x8c, 0x8f, 0xbf, 0x0f, 0x43, 0x45]

    func test_givenEmptyArray_whenHexEncodedStringComponents_thenReturnsEmptyArray() {
        // given
        let data = Array<UInt8>()

        // when
        let hexComponents = data.hexEncodedStringComponents()

        // then
        XCTAssertTrue(hexComponents.isEmpty)
    }

    func test_givenNonEmptyArray_whenHexEncodedStringComponents_thenReturnsExpectedComponents() {
        // given
        let data = Array(bytesStub)

        // when
        let hexComponents = data.hexEncodedStringComponents()

        // then
        XCTAssertEqual(
            ["ff", "36", "b4", "cb", "34", "ff", "8c", "8f", "bf", "0f", "43", "45"],
            hexComponents
        )
    }

    func test_givenNonEmptyArray_whenHexEncodedStringComponentsOptionsUpperCase_thenReturnsExpectedComponents() {
        // given
        let data = Array(bytesStub)

        // when
        let hexComponents = data.hexEncodedStringComponents(options: .upperCase)

        // then
        XCTAssertEqual(
            ["FF", "36", "B4", "CB", "34", "FF", "8C", "8F", "BF", "0F", "43", "45"],
            hexComponents
        )
    }

    func test_givenNonEmptyArray_whenHexEncodedStringComponentsOptionsNumericLiteral_thenReturnsExpectedComponents() {
        // given
        let data = Array(bytesStub)

        // when
        let hexComponents = data.hexEncodedStringComponents(options: .numericLiteral)

        // then
        XCTAssertEqual(
            ["0xff", "0x36", "0xb4", "0xcb", "0x34", "0xff", "0x8c", "0x8f", "0xbf", "0x0f", "0x43", "0x45"],
            hexComponents
        )
    }

    func test_givenNonEmptyArray_whenHexEncodedStringComponentsOptionsUpperCaseAndNumericLiteral_thenReturnsExpectedComponents() {
        // given
        let data = Array(bytesStub)

        // when
        let hexComponents = data.hexEncodedStringComponents(options: [.upperCase, .numericLiteral])

        // then
        XCTAssertEqual(
            ["0xFF", "0x36", "0xB4", "0xCB", "0x34", "0xFF", "0x8C", "0x8F", "0xBF", "0x0F", "0x43", "0x45"],
            hexComponents
        )
    }
}
