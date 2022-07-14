@testable import ConfidentialKit
import XCTest

final class DataCompressorTests: XCTestCase {

    private typealias Algorithm = Obfuscation.Compression.CompressionAlgorithm
    private typealias DataCompressor = Obfuscation.Compression.DataCompressor

    private let plainData: Data = SingleValue.StubFactory.makeSecretMessageData()
    private let compressionAlgorithms: [Algorithm] = [
        .lzfse, .lz4, .lzma, .zlib
    ]

    func test_givenCompressedData_whenDeobfuscate_thenReturnsDecompressedData() throws {
        // given
        let compressedData = compressionAlgorithms
            .map { algorithm in
                (
                    algorithm,
                    Data(referencing: try! NSData(data: plainData).compressed(using: algorithm))
                )
            }

        // when
        let decompressedData = try compressedData
            .map { algorithm, data in
                try DataCompressor(algorithm: algorithm).deobfuscate(data)
            }

        // then
        decompressedData.forEach { XCTAssertEqual(plainData, $0) }
    }
}
