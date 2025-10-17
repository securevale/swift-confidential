@testable import ConfidentialKitMacros
import Foundation

final class DataEncoderSpy: DataEncoder {

    var encodeReturnValue: Data
    var underlyingEncoder: (any DataEncoder)?

    private(set) var encodeRecordedValues: [any Encodable] = []

    init(encodeReturnValue: Data) {
        self.encodeReturnValue = encodeReturnValue
    }

    func encode<E: Encodable>(_ value: E) throws -> Data {
        encodeRecordedValues.append(value)
        if let underlyingEncoder {
            return try underlyingEncoder.encode(value)
        }
        return encodeReturnValue
    }
}
