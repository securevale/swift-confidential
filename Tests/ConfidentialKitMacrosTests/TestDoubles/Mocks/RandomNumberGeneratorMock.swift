struct RandomNumberGeneratorMock: RandomNumberGenerator {

    private let nextValues: [UInt64]
    private var index: Int = .zero

    init(nextValues: [UInt64]) {
        assert(!nextValues.isEmpty)
        self.nextValues = nextValues
    }

    mutating func next() -> UInt64 {
        guard index < nextValues.count else { return nextValues.last! }
        defer { index += 1 }
        return nextValues[index]
    }
}
