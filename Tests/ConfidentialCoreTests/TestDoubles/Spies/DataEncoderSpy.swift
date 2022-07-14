@testable import ConfidentialCore
import Foundation

final class DataEncoderSpy: DataEncoder {

    var underlyingEncoder: DataEncoder

    private(set) var encodeRecordedValues: [any Encodable] = []

    init(underlyingEncoder: DataEncoder) {
        self.underlyingEncoder = underlyingEncoder
    }

    func encode<E: Encodable>(_ value: E) throws -> Data {
        encodeRecordedValues.append(value)
        return try underlyingEncoder.encode(value)
    }
}
