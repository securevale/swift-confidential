@testable import ConfidentialCore
import XCTest

final class DataShufflerTests: XCTestCase {

    private typealias SUT = Obfuscation.Randomization.DataShuffler

    private var sut: SUT!

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
        let shuffledData = shuffledDataStub

        // when
        let deshuffledData = try shuffledData
            .map { params, data in
                try sut.deobfuscate(data, nonce: params.nonce)
            }

        // then
        deshuffledData.forEach { XCTAssertEqual(plainData, $0) }
    }
}

private extension DataShufflerTests {

    struct RandomizationParams {
        let nonce: Obfuscation.Nonce
    }

    var plainData: Data {
        .init([0x5d, 0x9b, 0xe7, 0xde])
    }

    var shuffledDataStub: [(RandomizationParams, Data)] {
        [
            (
                .init(
                    nonce: 3683273644876213525
                //  indexByteWidth: 1
                ),
                .init([
                    0x11, 0xad, 0x67, 0x7d, 0xdd, 0x9d, 0x1d, 0x33, 0x9b, 0xe7, 0xde, 0x5d,
                    0x01, 0x16, 0x15, 0x14, 0x17
                ])
            ),
            (
                .init(
                    nonce: 2467393122768582588
                //  indexByteWidth: 2
                ),
                .init([
                    0xb8, 0xf7, 0xdc, 0xeb, 0xf8, 0xf0, 0x3d, 0x22, 0xe7, 0x9b, 0x5d, 0xde,
                    0x02, 0xbe, 0xf7, 0xbd, 0xf7, 0xbc, 0xf7, 0xbf, 0xf7
                ])
            ),
            (
                .init(
                    nonce: 11699582232143540816
                //  indexByteWidth: 8
                ),
                .init([
                    0x54, 0x32, 0x63, 0x97, 0x0d, 0x44, 0x5d, 0xa2, 0xde, 0xe7, 0x5d, 0x9b,
                    0x08, 0x52, 0x32, 0x63, 0x97, 0x0d, 0x44, 0x5d, 0xa2, 0x53, 0x32, 0x63,
                    0x97, 0x0d, 0x44, 0x5d, 0xa2, 0x51, 0x32, 0x63, 0x97, 0x0d, 0x44, 0x5d,
                    0xa2, 0x50, 0x32, 0x63, 0x97, 0x0d, 0x44, 0x5d, 0xa2
                ])
            )
        ]
    }
}
