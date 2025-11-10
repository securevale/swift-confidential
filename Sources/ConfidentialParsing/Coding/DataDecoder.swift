import Foundation
import class Yams.YAMLDecoder

protocol DataDecoder {
    func decode<D: Decodable>(_ type: D.Type, from data: Data) throws -> D
}

extension JSONDecoder: DataDecoder {}
extension YAMLDecoder: DataDecoder {}
