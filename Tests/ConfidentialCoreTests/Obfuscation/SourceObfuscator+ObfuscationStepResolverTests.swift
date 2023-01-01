@testable import ConfidentialCore
import XCTest

import ConfidentialKit

final class SourceObfuscator_ObfuscationStepResolverTests: XCTestCase {

    private typealias Technique = SourceSpecification.ObfuscationStep.Technique

    func test_givenObfuscationStepResolver_whenObfuscationStepForTechnique_thenReturnsExpectedObfuscationStepInstance() {
        // given
        let compressionTechnique = Technique.compression(algorithm: .lz4)
        let encryptionTechnique = Technique.encryption(algorithm: .aes128GCM)
        let randomizationTechnique = Technique.randomization
        let techniques: [Technique] = [
            compressionTechnique,
            encryptionTechnique,
            randomizationTechnique
        ]
        let resolver = SourceObfuscator.ObfuscationStepResolver()

        // when
        let obfuscationSteps: [Technique: any DataObfuscationStep] = .init(
            uniqueKeysWithValues: techniques.map {
                let step = resolver.obfuscationStep(for: $0)
                return ($0, step)
            }
        )

        // then
        XCTAssertTrue(obfuscationSteps[compressionTechnique] is Obfuscation.Compression.DataCompressor)
        XCTAssertTrue(obfuscationSteps[encryptionTechnique] is Obfuscation.Encryption.DataCrypter)
        XCTAssertTrue(obfuscationSteps[randomizationTechnique] is Obfuscation.Randomization.DataShuffler)
    }
}
