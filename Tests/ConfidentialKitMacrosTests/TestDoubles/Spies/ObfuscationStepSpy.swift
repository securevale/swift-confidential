@testable import ConfidentialKitMacros

import ConfidentialCore
import Foundation

final class ObfuscationStepSpy: DataObfuscationStep {

    var obfuscateReturnValue: Data?

    private(set) var recordedData: [Data] = []
    private(set) var recordedNonces: [Obfuscation.Nonce] = []

    func obfuscate(_ data: Data, nonce: Obfuscation.Nonce) throws -> Data {
        recordedData.append(data)
        recordedNonces.append(nonce)
        return obfuscateReturnValue ?? data
    }
}
