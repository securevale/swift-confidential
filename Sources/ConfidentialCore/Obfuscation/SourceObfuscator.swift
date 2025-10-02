import ConfidentialKit
import Foundation

package struct SourceObfuscator {

    private let obfuscationStepResolver: DataObfuscationStepResolver

    init(obfuscationStepResolver: DataObfuscationStepResolver) {
        self.obfuscationStepResolver = obfuscationStepResolver
    }

    package func obfuscate(_ source: inout SourceFileSpec) throws {
        guard !source.secrets.isEmpty else {
            return
        }

        let obfuscateData = obfuscationFunc(given: source.algorithm)
        try source.secrets.namespaces.forEach { namespace in
            guard let secrets = source.secrets[namespace] else {
                fatalError("Unexpected source file spec integrity violation")
            }

            source.secrets[namespace] = try secrets.map { secret in
                var secret = secret
                secret.data = try obfuscateData(secret.data, secret.nonce)
                return secret
            }[...]
        }
    }
}

private extension SourceObfuscator {

    typealias Algorithm = SourceFileSpec.Algorithm
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
