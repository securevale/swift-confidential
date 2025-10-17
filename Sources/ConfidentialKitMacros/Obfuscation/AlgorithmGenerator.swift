import ConfidentialCore

protocol AlgorithmGenerator {
    mutating func generateAlgorithm() -> Obfuscation.Algorithm
}

extension AlgorithmGenerator {

    func generateAlgorithm() -> Obfuscation.Algorithm {
        var mutableSelf = self
        return mutableSelf.generateAlgorithm()
    }
}

struct RandomAlgorithmGenerator: AlgorithmGenerator {

    private var randomNumberGenerator: any RandomNumberGenerator

    init(randomNumberGenerator: any RandomNumberGenerator) {
        self.randomNumberGenerator = randomNumberGenerator
    }

    mutating func generateAlgorithm() -> Obfuscation.Algorithm {
        guard let compressionAlgorithm, let encryptionAlgorithm else { return [] }

        var obfuscationSteps: [Obfuscation.Step] = [
            .compress(algorithm: compressionAlgorithm),
            .encrypt(algorithm: encryptionAlgorithm),
            .shuffle
        ]

        obfuscationSteps.shuffle(using: &randomNumberGenerator)

        return obfuscationSteps
    }
}

private extension RandomAlgorithmGenerator {

    typealias CompressionAlgorithm = Obfuscation.Compression.CompressionAlgorithm
    typealias EncryptionAlgorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm

    var compressionAlgorithm: CompressionAlgorithm? {
        mutating get {
            .allCases.randomElement(using: &randomNumberGenerator)
        }
    }

    var encryptionAlgorithm: EncryptionAlgorithm? {
        mutating get {
            .allCases.randomElement(using: &randomNumberGenerator)
        }
    }
}
