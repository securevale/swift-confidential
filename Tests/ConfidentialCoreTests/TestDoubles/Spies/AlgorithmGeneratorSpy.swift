@testable import ConfidentialCore

final class AlgorithmGeneratorSpy: AlgorithmGenerator {

    var generateAlgorithmReturnValue: Algorithm

    private(set) var generateAlgorithmCallCount: Int = .zero

    init(generateAlgorithmReturnValue: Algorithm) {
        self.generateAlgorithmReturnValue = generateAlgorithmReturnValue
    }

    func generateAlgorithm() -> Algorithm {
        generateAlgorithmCallCount += 1
        return generateAlgorithmReturnValue
    }
}
