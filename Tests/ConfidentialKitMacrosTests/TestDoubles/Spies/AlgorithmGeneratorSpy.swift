@testable import ConfidentialKitMacros

import ConfidentialCore

final class AlgorithmGeneratorSpy: AlgorithmGenerator {

    var generateAlgorithmReturnValue: Obfuscation.Algorithm

    private(set) var generateAlgorithmCallCount: Int = .zero

    init(generateAlgorithmReturnValue: Obfuscation.Algorithm) {
        self.generateAlgorithmReturnValue = generateAlgorithmReturnValue
    }

    func generateAlgorithm() -> Obfuscation.Algorithm {
        generateAlgorithmCallCount += 1
        return generateAlgorithmReturnValue
    }
}
