@testable import ConfidentialKit
import XCTest

final class DataShufflerTests: XCTestCase {

    private typealias DataShuffler = Obfuscation.Randomization.DataShuffler

    private let nonce: Obfuscation.Nonce = .StubFactory.makeNonce()

    private var sut: DataShuffler!

    override func setUp() {
        super.setUp()
        sut = .init()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_givenShuffledData_whenDeobfuscate_thenReturnsDeshuffledData() throws {
        // given
        let plainData: [Data] = [
            .init([0x5d, 0x9b, 0xe7, 0xde]),
            .init([0xe4, 0xe3, 0x34, 0xd8]),
            .init([0x55, 0x2a, 0x49, 0x30])
        ]
        let count = Int(4 ^ nonce)
        let shuffledIndexes = [3, 0, 2, 1]
        let shuffledData = plainData.enumerated().map { idx, data -> Data in
            let dataBytes = reorderBytes(.init(data), given: shuffledIndexes)
            let indexesByteWidth = UInt8(1 << idx)
            let obfuscatedIndexes = obfuscateIndexes(
                shuffledIndexes,
                byteWidth: indexesByteWidth
            )
            return Data(
                count.bytes + dataBytes + [indexesByteWidth] + obfuscatedIndexes
            )
        }

        // when
        let deshuffledData = try shuffledData.map { try sut.deobfuscate($0, nonce: nonce) }

        // then
        XCTAssertEqual(plainData, deshuffledData)
    }
}

private extension DataShufflerTests {

    func reorderBytes(_ bytes: [UInt8], given indexes: [Int]) -> [UInt8] {
        var result: [UInt8] = .init(repeating: .zero, count: bytes.count)
        indexes.enumerated().forEach { oldIdx, newIdx in
            result[newIdx] = bytes[oldIdx]
        }

        return result
    }

    func obfuscateIndexes(_ indexes: [Int], byteWidth: UInt8) -> [UInt8] {
        switch Int(byteWidth) {
        case UInt8.byteWidth:
            return indexes
                .map(UInt8.init)
                .map { $0 ^ .init(bytes: nonce.bytes) }
        case UInt16.byteWidth:
            return indexes
                .map(UInt16.init)
                .flatMap { withUnsafeBytes(of: $0 ^ .init(bytes: nonce.bytes), [UInt8].init) }
        default:
            return indexes
                .flatMap { withUnsafeBytes(of: $0 ^ .init(bytes: nonce.bytes), [UInt8].init) }
        }
    }
}
