@testable import ConfidentialCore
import XCTest

import ConfidentialKit

final class DataCompressor_DataObfuscationStepTests: XCTestCase {

    private typealias SUT = Obfuscation.Compression.DataCompressor

    func test_givenPlainData_whenObfuscate_thenCompressedDataEqualsExpectedData() throws {
        // given
        let plainData = plainData

        // when & then
        try compressedDataStub.forEach { params, expectedData in
            let sut = SUT(algorithm: params.algorithm)
            let compressedData = try sut.obfuscate(plainData, nonce: params.nonce)
            XCTAssertEqual(expectedData, compressedData)
        }
    }

    func test_givenCompressedDataAfterObfuscateCall_whenDeobfuscate_thenReturnsDecompressedData() throws {
        // given
        let plainData = plainData
        let compressedData = try compressedDataStub.map { params, _ in
            let sut = SUT(algorithm: params.algorithm)
            return (
                params,
                try sut.obfuscate(plainData, nonce: params.nonce)
            )
        }

        // when
        let decompressedData = try compressedData.map { params, data in
            let sut = SUT(algorithm: params.algorithm)
            return try sut.deobfuscate(data, nonce: params.nonce)
        }

        // then
        decompressedData.forEach { XCTAssertEqual(plainData, $0) }
    }
}

private extension DataCompressor_DataObfuscationStepTests {

    typealias Algorithm = Obfuscation.Compression.CompressionAlgorithm

    struct CompressionParams {
        let algorithm: Algorithm
        let nonce: Obfuscation.Nonce
    }

    var plainData: Data {
        .init([
            0x53, 0x65, 0x63, 0x72, 0x65, 0x74, 0x20, 0x6d, 0x65, 0x73, 0x73, 0x61,
            0x67, 0x65, 0x20, 0xf0, 0x9f, 0x94, 0x90
        ])
    }

    var compressedDataStub: [(CompressionParams, Data)] {
        [
            (
                .init(
                    algorithm: .lzfse,
                    nonce: 3683273644876213525
                ),
                .init([
                    0x77, 0xdb, 0x1f, 0x50, 0x13, 0x00, 0x00, 0x00, 0x53, 0x65, 0x63, 0x72,
                    0x65, 0x74, 0x20, 0x6d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x20, 0xf0,
                    0x9f, 0x94, 0x90, 0x51, 0x6b, 0xe5, 0xf9
                ])
            ),
            (
                .init(
                    algorithm: .lz4,
                    nonce: 2467393122768582588
                ),
                .init([
                    0xde, 0x81, 0xe8, 0xc6, 0x13, 0x00, 0x00, 0x00, 0x53, 0x65, 0x63, 0x72,
                    0x65, 0x74, 0x20, 0x6d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x20, 0xf0,
                    0x9f, 0x94, 0x90, 0x40, 0x4b, 0xc4, 0xdc
                ])
            ),
            (
                .init(
                    algorithm: .lzma,
                    nonce: 11699582232143540816
                ),
                .init([
                    0xad, 0x05, 0x19, 0xcf, 0x57, 0x44, 0x00, 0x00, 0xff, 0x12, 0xd9, 0x41,
                    0x02, 0x00, 0x21, 0x01, 0x16, 0x00, 0x00, 0x00, 0x74, 0x2f, 0xe5, 0xa3,
                    0x01, 0x00, 0x12, 0x53, 0x65, 0x63, 0x72, 0x65, 0x74, 0x20, 0x6d, 0x65,
                    0x73, 0x73, 0x61, 0x67, 0x65, 0x20, 0xf0, 0x9f, 0x94, 0x90, 0x00, 0x00,
                    0x00, 0x01, 0x23, 0x13, 0x94, 0x83, 0x91, 0x1a, 0x06, 0x72, 0x9e, 0x7a,
                    0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfb, 0x07
                ])
            ),
            (
                .init(
                    algorithm: .zlib,
                    nonce: 4110998048993541303
                ),
                .init([
                    0x0b, 0x4e, 0x4d, 0x2e, 0x4a, 0x2d, 0x51, 0xc8, 0x4d, 0x2d, 0x2e, 0x4e,
                    0x4c, 0x4f, 0x55, 0xf8, 0x30, 0x7f, 0xca, 0x04, 0x00
                ])
            )
        ]
    }
}
