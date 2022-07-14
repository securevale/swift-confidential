@testable import ConfidentialKit
import Foundation

final class DataDecoderSpy: DataDecoder {

    var underlyingDecoder: DataDecoder

    private(set) var decodeRecordedData: [Data] = []

    init(underlyingDecoder: DataDecoder) {
        self.underlyingDecoder = underlyingDecoder
    }

    func decode<D: Decodable>(_ type: D.Type, from data: Data) throws -> D {
        decodeRecordedData.append(data)
        return try underlyingDecoder.decode(type, from: data)
    }
}
