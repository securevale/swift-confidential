@testable import ConfidentialUtils
import XCTest

final class NSData_CompressionAlgorithm_MagicNumbersTests: XCTestCase {

    private typealias SUT = NSData.CompressionAlgorithm

    func test_whenHeaderMagicByteCount_thenReturnsExpectedNumberOfBytes() {
        XCTAssertEqual(4, SUT.lzfse.headerMagicByteCount)
        XCTAssertEqual(4, SUT.lz4.headerMagicByteCount)
        XCTAssertEqual(6, SUT.lzma.headerMagicByteCount)
        XCTAssertEqual(0, SUT.zlib.headerMagicByteCount)
    }

    func test_whenFooterMagicByteCount_thenReturnsExpectedNumberOfBytes() {
        XCTAssertEqual(4, SUT.lzfse.footerMagicByteCount)
        XCTAssertEqual(4, SUT.lz4.footerMagicByteCount)
        XCTAssertEqual(2, SUT.lzma.footerMagicByteCount)
        XCTAssertEqual(0, SUT.zlib.footerMagicByteCount)
    }
}
