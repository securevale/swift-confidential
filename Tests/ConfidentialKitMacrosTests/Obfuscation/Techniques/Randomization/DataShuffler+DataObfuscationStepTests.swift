@testable import ConfidentialKitMacros
import XCTest

import ConfidentialCore

final class DataShuffler_DataObfuscationStepTests: XCTestCase {

    private typealias SUT = Obfuscation.Randomization.DataShuffler

    private let nonceStub: Obfuscation.Nonce = 14977856632874584036

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        sut = .init()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_givenPlainData_whenObfuscate_thenShuffledDataIsOfExpectedSize() throws {
        // given
        let plainData: [Int: Data] = [
            UInt8.byteWidth: .init(count: .init(UInt8.max) + 1),
            UInt16.byteWidth: .init(count: .init(UInt16.max) + 1),
            Int.byteWidth: .init(count: .init(UInt16.max) + 2)
        ]

        // when
        let shuffledData = try plainData.values.map {
            try sut.obfuscate($0, nonce: nonceStub)
        }

        // then
        let expectedCountSize = 8
        let expectedIndexByteWidthSize = 1
        let expectedSizes = plainData.map { byteWidth, data in
            expectedCountSize + data.count * (1 + byteWidth) + expectedIndexByteWidthSize
        }
        shuffledData.enumerated().forEach { idx, shuffledData in
            XCTAssertEqual(expectedSizes[idx], shuffledData.count)
        }
    }

    func test_givenShuffledDataAfterObfuscateCall_whenDeobfuscate_thenReturnsDeshuffledData() throws {
        // given
        let plainData: Data = .init([
            0xf0, 0x8d, 0x65, 0x7e, 0xfa, 0x4f, 0xd9, 0x37, 0xca, 0xd7, 0x59, 0xd3,
            0x21, 0x09, 0xe7, 0xc0
        ])
        let shuffledData = try sut.obfuscate(plainData, nonce: nonceStub)

        // when
        let deshuffledData = try sut.deobfuscate(shuffledData, nonce: nonceStub)

        // then
        XCTAssertEqual(plainData, deshuffledData)
    }
}
