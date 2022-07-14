import ConfidentialKit
import Foundation

extension Obfuscation.Compression.DataCompressor: DataObfuscationStep {

    func obfuscate(_ data: Data) throws -> Data {
        let compressedData = try NSData(data: data).compressed(using: algorithm)
        return .init(referencing: compressedData)
    }
}
