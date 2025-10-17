import ConfidentialCore
import Foundation

struct SecretObfuscator {

    typealias Secret = Obfuscation.Secret
    typealias Algorithm = Obfuscation.Algorithm

    private let obfuscationStepResolver: DataObfuscationStepResolver

    init(obfuscationStepResolver: DataObfuscationStepResolver) {
        self.obfuscationStepResolver = obfuscationStepResolver
    }

    func obfuscate(_ secret: inout Secret, using algorithm: Algorithm) throws {
        guard !secret.data.isEmpty else { return }

        let plainData = Data(secret.data)
        let nonce = secret.nonce

        let obfuscateData = obfuscationFunc(given: algorithm)
        let obfuscatedData = try obfuscateData(plainData, nonce)

        secret.data = .init(obfuscatedData)
    }
}

private extension SecretObfuscator {

    typealias Nonce = Obfuscation.Nonce
    typealias ObfuscationFunc = (Data, Nonce) throws -> Data

    @inline(__always)
    func obfuscationFunc(given algorithm: Algorithm) -> ObfuscationFunc {
        algorithm
            .map(obfuscationStepResolver.implementation(for:))
            .reduce({ data, _ in data }, { partialFunc, step in
                return {
                    try step.obfuscate(partialFunc($0, $1), nonce: $1)
                }
            })
    }
}
