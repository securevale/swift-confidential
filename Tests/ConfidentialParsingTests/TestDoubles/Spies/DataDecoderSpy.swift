@testable import ConfidentialParsing
import Foundation

final class DataDecoderSpy: DataDecoder {

    var underlyingDecoder: any DataDecoder

    private(set) var decodeRecordedData: [Data] = []

    init(underlyingDecoder: any DataDecoder) {
        self.underlyingDecoder = underlyingDecoder
    }

    func decode<D: Decodable>(_ type: D.Type, from data: Data) throws -> D {
        decodeRecordedData.append(data)
        return try underlyingDecoder.decode(type, from: data)
    }
}
