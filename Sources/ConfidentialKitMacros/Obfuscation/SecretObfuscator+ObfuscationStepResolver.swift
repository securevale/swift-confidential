import ConfidentialCore

protocol DataObfuscationStepResolver {

    func implementation(for step: Obfuscation.Step) -> any DataObfuscationStep
}

extension SecretObfuscator {

    struct ObfuscationStepResolver: DataObfuscationStepResolver {

        @inline(__always)
        func implementation(for step: Obfuscation.Step) -> any DataObfuscationStep {
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

extension SecretObfuscator {

    init() {
        self.init(obfuscationStepResolver: ObfuscationStepResolver())
    }
}
