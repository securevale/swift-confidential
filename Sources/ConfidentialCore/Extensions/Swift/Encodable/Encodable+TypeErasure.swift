struct AnyEncodable: Encodable {

    private let encode: (Encoder) throws -> Void

    init(_ encodable: any Encodable) {
        self.encode = encodable.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}

extension Encodable {

    func eraseToAnyEncodable() -> AnyEncodable {
        .init(self)
    }
}
