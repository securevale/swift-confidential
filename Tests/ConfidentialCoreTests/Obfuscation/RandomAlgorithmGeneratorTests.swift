@testable import ConfidentialCore
import XCTest

final class RandomAlgorithmGeneratorTests: XCTestCase {

    private typealias SUT = RandomAlgorithmGenerator

    func test_givenRandomNumberGenerator_whenGenerateAlgorithm_thenReturnsExpectedAlgorithm() {
        // given
        let randomNumberGenerators = [
            RandomNumberGeneratorMock(nextValues: [UInt64.max / 2]),
            RandomNumberGeneratorMock(nextValues: [UInt64.max / 4])
        ]

        // when
        let algorithms = randomNumberGenerators.map {
            SUT(randomNumberGenerator: $0).generateAlgorithm()
        }

        // then
        XCTAssertEqual(
            [
                [
                    .encrypt(algorithm: .aes192GCM),
                    .compress(algorithm: .lz4),
                    .shuffle
                ],
                [
                    .compress(algorithm: .lzfse),
                    .encrypt(algorithm: .aes128GCM),
                    .shuffle
                ]
            ],
            algorithms
        )
    }
}
