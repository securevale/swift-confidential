import ConfidentialCore
import Foundation

extension ObfuscateMacro {

    struct Configuration {
        let algorithmGenerator: any AlgorithmGenerator
        let generateNonce: () throws -> Obfuscation.Nonce
        let secretObfuscator: SecretObfuscator
        let secretValueEncoder: any DataEncoder
    }

    nonisolated(unsafe) static var configuration = Configuration(
        algorithmGenerator: RandomAlgorithmGenerator(randomNumberGenerator: .system),
        generateNonce: { try .secureRandom() },
        secretObfuscator: SecretObfuscator(),
        secretValueEncoder: JSONEncoder()
    )
}
