@testable import ConfidentialKitMacros

import ConfidentialCore

final class ObfuscationStepResolverSpy: DataObfuscationStepResolver {

    var implementationReturnValue: any DataObfuscationStep

    private(set) var recordedSteps: [Obfuscation.Step] = []

    init(implementationReturnValue: any DataObfuscationStep) {
        self.implementationReturnValue = implementationReturnValue
    }

    func implementation(for step: Obfuscation.Step) -> DataObfuscationStep {
        recordedSteps.append(step)
        return implementationReturnValue
    }
}
