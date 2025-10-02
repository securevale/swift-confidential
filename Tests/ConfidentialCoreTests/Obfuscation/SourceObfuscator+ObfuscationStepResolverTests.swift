@testable import ConfidentialCore
import XCTest

import ConfidentialKit

final class SourceObfuscator_ObfuscationStepResolverTests: XCTestCase {

    private typealias ObfuscationStep = SourceFileSpec.ObfuscationStep

    private typealias SUT = SourceObfuscator.ObfuscationStepResolver

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        sut = .init()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_givenObfuscationStepResolver_whenImplementationForStep_thenReturnsExpectedObfuscationStepInstance() {
        // given
        let compressStep = ObfuscationStep.compress(algorithm: .lz4)
        let encryptStep = ObfuscationStep.encrypt(algorithm: .aes128GCM)
        let shuffleStep = ObfuscationStep.shuffle
        let obfuscationSteps: [ObfuscationStep] = [
            compressStep,
            encryptStep,
            shuffleStep
        ]

        // when
        let implementations: [ObfuscationStep: any DataObfuscationStep] = .init(
            uniqueKeysWithValues: obfuscationSteps.map {
                let implementation = sut.implementation(for: $0)
                return ($0, implementation)
            }
        )

        // then
        XCTAssertTrue(implementations[compressStep] is Obfuscation.Compression.DataCompressor)
        XCTAssertTrue(implementations[encryptStep] is Obfuscation.Encryption.DataCrypter)
        XCTAssertTrue(implementations[shuffleStep] is Obfuscation.Randomization.DataShuffler)
    }
}
