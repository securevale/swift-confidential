import ConfidentialKit

protocol AlgorithmGenerator {

    typealias Algorithm = SourceFileSpec.Algorithm

    mutating func generateAlgorithm() -> Algorithm
}

extension AlgorithmGenerator {

    func generateAlgorithm() -> Algorithm {
        var mutableSelf = self
        return mutableSelf.generateAlgorithm()
    }
}

struct RandomAlgorithmGenerator: AlgorithmGenerator {

    private typealias ObfuscationStep = SourceFileSpec.ObfuscationStep

    private var randomNumberGenerator: any RandomNumberGenerator

    init(randomNumberGenerator: any RandomNumberGenerator) {
        self.randomNumberGenerator = randomNumberGenerator
    }

    mutating func generateAlgorithm() -> Algorithm {
        guard let compressionAlgorithm, let encryptionAlgorithm else { return [] }

        var obfuscationSteps: [ObfuscationStep] = [
            .compress(algorithm: compressionAlgorithm),
            .encrypt(algorithm: encryptionAlgorithm),
            .shuffle
        ]

        obfuscationSteps.shuffle(using: &randomNumberGenerator)

        return obfuscationSteps[...]
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
