@testable import ConfidentialCore

final class ObfuscationStepResolverSpy: DataObfuscationStepResolver {

    var implementationReturnValue: any DataObfuscationStep

    private(set) var recordedSteps: [Step] = []

    init(implementationReturnValue: any DataObfuscationStep) {
        self.implementationReturnValue = implementationReturnValue
    }

    func implementation(for step: Step) -> DataObfuscationStep {
        recordedSteps.append(step)
        return implementationReturnValue
    }
}
