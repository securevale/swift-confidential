import ConfidentialKit

protocol DataObfuscationStepResolver {

    typealias Technique = SourceSpecification.ObfuscationStep.Technique

    func obfuscationStep(for technique: Technique) -> any DataObfuscationStep
}

extension SourceObfuscator {

    struct ObfuscationStepResolver: DataObfuscationStepResolver {

        @inline(__always)
        func obfuscationStep(for technique: Technique) -> any DataObfuscationStep {
            switch technique {
            case let .compression(algorithm):
                return Obfuscation.Compression.DataCompressor(algorithm: algorithm)
            case let .encryption(algorithm):
                return Obfuscation.Encryption.DataCrypter(algorithm: algorithm)
            case let .randomization(nonce):
                return Obfuscation.Randomization.DataShuffler(nonce: nonce)
            }
        }
    }
}

public extension SourceObfuscator {

    init() {
        self.init(obfuscationStepResolver: ObfuscationStepResolver())
    }
}
