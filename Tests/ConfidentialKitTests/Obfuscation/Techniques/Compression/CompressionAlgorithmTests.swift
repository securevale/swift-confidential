@testable import ConfidentialKit
import XCTest

final class CompressionAlgorithmTests: XCTestCase {

    private typealias Algorithm = Obfuscation.Compression.CompressionAlgorithm

    func test_whenHeaderMagicByteCount_thenReturnsExpectedNumberOfBytes() {
        XCTAssertEqual(4, Algorithm.lzfse.headerMagicByteCount)
        XCTAssertEqual(4, Algorithm.lz4.headerMagicByteCount)
        XCTAssertEqual(6, Algorithm.lzma.headerMagicByteCount)
        XCTAssertEqual(.zero, Algorithm.zlib.headerMagicByteCount)
    }

    func test_whenFooterMagicByteCount_thenReturnsExpectedNumberOfBytes() {
        XCTAssertEqual(4, Algorithm.lzfse.footerMagicByteCount)
        XCTAssertEqual(4, Algorithm.lz4.footerMagicByteCount)
        XCTAssertEqual(2, Algorithm.lzma.footerMagicByteCount)
        XCTAssertEqual(.zero, Algorithm.zlib.footerMagicByteCount)
    }
}
