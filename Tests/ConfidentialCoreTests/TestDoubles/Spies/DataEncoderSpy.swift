@testable import ConfidentialCore
import Foundation

final class DataEncoderSpy: DataEncoder {

    var underlyingEncoder: any DataEncoder

    private(set) var encodeRecordedValues: [any Encodable] = []

    init(underlyingEncoder: any DataEncoder) {
        self.underlyingEncoder = underlyingEncoder
    }

    func encode<E: Encodable>(_ value: E) throws -> Data {
        encodeRecordedValues.append(value)
        return try underlyingEncoder.encode(value)
    }
}
