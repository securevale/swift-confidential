import ConfidentialKit
import Foundation

final class DeobfuscateDataFuncSpy {

    private(set) var recordedData: [Data] = []
    private(set) var recordedNonces: [Obfuscation.Nonce] = []

    func deobfuscateData(_ data: Data, nonce: Obfuscation.Nonce) -> Data {
        recordedData.append(data)
        recordedNonces.append(nonce)
        return data
    }
}
