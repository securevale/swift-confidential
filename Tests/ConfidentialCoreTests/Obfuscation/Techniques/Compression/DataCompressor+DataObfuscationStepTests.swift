@testable import ConfidentialCore
import XCTest

import ConfidentialKit

final class DataCompressor_DataObfuscationStepTests: XCTestCase {

    private typealias Algorithm = Obfuscation.Compression.CompressionAlgorithm
    private typealias DataCompressor = Obfuscation.Compression.DataCompressor

    private let compressionAlgorithms: [Algorithm] = [
        .lzfse, .lz4, .lzma, .zlib
    ]

    func test_givenPlainData_whenObfuscate_thenCompressedDataNotEmptyAndNotEqualToPlainData() throws {
        // given
        let plainData: Data = .init(
            [0x2e, 0xea, 0xf5, 0xef, 0xa5, 0xda, 0x5d, 0xfd, 0x4a, 0x72, 0xd6, 0x97]
        )

        // when
        let compressedData = try compressionAlgorithms.map {
            try DataCompressor(algorithm: $0).obfuscate(plainData)
        }

        // then
        compressedData.forEach {
            XCTAssertFalse($0.isEmpty)
            XCTAssertNotEqual(plainData, $0)
        }
    }

    func test_givenCompressedDataAfterObfuscateCall_whenDeobfuscate_thenReturnsDecompressedData() throws {
        // given
        let plainData: Data = .init(
            [0xdf, 0xc8, 0x72, 0x04, 0x6b, 0xbf, 0xe5, 0x54, 0x33, 0x0e, 0xc2, 0x4f]
        )
        let compressedData = try compressionAlgorithms.map {
            ($0, try DataCompressor(algorithm: $0).obfuscate(plainData))
        }

        // when
        let decompressedData = try compressedData.map {
            try DataCompressor(algorithm: $0.0).deobfuscate($0.1)
        }

        // then
        decompressedData.forEach { XCTAssertEqual(plainData, $0) }
    }
}
