@testable import ConfidentialCore

final class ObfuscationStepResolverSpy: DataObfuscationStepResolver {

    var obfuscationStepReturnValue: any DataObfuscationStep

    private(set) var recordedTechniques: [Technique] = []

    init(obfuscationStepReturnValue: any DataObfuscationStep) {
        self.obfuscationStepReturnValue = obfuscationStepReturnValue
    }

    func obfuscationStep(for technique: Technique) -> DataObfuscationStep {
        recordedTechniques.append(technique)
        return obfuscationStepReturnValue
    }
}
