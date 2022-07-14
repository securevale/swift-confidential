import Foundation

final class DeobfuscateDataFuncSpy {

    private(set) var recordedData: [Data] = []

    func deobfuscateData(_ data: Data) -> Data {
        recordedData.append(data)
        return data
    }
}
