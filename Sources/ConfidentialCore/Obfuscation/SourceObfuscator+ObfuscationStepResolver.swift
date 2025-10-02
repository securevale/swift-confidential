import ConfidentialKit

protocol DataObfuscationStepResolver {

    typealias Step = SourceFileSpec.ObfuscationStep

    func implementation(for step: Step) -> any DataObfuscationStep
}

extension SourceObfuscator {

    struct ObfuscationStepResolver: DataObfuscationStepResolver {

        @inline(__always)
        func implementation(for step: Step) -> any DataObfuscationStep {
            switch step {
            case let .compress(algorithm):
                return Obfuscation.Compression.DataCompressor(algorithm: algorithm)
            case let .encrypt(algorithm):
                return Obfuscation.Encryption.DataCrypter(algorithm: algorithm)
            case .shuffle:
                return Obfuscation.Randomization.DataShuffler()
            }
        }
    }
}

package extension SourceObfuscator {

    init() {
        self.init(obfuscationStepResolver: ObfuscationStepResolver())
    }
}
