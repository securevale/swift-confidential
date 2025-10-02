final class EncodableSpy<Value: Encodable>: Encodable {

    var encodableValue: Value?

    private(set) var encodeCallCount: Int = .zero

    func encode(to encoder: Encoder) throws {
        encodeCallCount += 1
        guard let encodableValue else { return }
        var container = encoder.singleValueContainer()
        try container.encode(encodableValue)
    }
}
