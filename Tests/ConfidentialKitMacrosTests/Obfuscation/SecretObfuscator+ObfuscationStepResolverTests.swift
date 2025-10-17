@testable import ConfidentialKitMacros
import XCTest

import ConfidentialCore

final class SecretObfuscator_ObfuscationStepResolverTests: XCTestCase {

    private typealias SUT = SecretObfuscator.ObfuscationStepResolver

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
        let compressStep = Obfuscation.Step.compress(algorithm: .lz4)
        let encryptStep = Obfuscation.Step.encrypt(algorithm: .aes128GCM)
        let shuffleStep = Obfuscation.Step.shuffle
        let obfuscationSteps: [Obfuscation.Step] = [
            compressStep,
            encryptStep,
            shuffleStep
        ]

        // when
        let implementations: [Obfuscation.Step: any DataObfuscationStep] = .init(
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
