@testable import ConfidentialCore
import Foundation

final class ObfuscationStepSpy: DataObfuscationStep {

    var obfuscateReturnValue: Data?

    private(set) var recordedData: [Data] = []

    func obfuscate(_ data: Data) throws -> Data {
        recordedData.append(data)
        return obfuscateReturnValue ?? data
    }
}
