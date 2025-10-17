import Foundation

protocol DataEncoder {
    func encode<E: Encodable>(_ value: E) throws -> Data
}

extension JSONEncoder: DataEncoder {}
