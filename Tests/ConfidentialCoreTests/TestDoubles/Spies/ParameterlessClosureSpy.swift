final class ParameterlessClosureSpy<Result> {

    var result: Result
    var error: (any Error)?

    private(set) var callCount: Int = .zero

    init(result: Result) {
        self.result = result
    }

    func closure() -> Result {
        callCount += 1
        return result
    }

    func closureWithError() throws -> Result {
        callCount += 1
        if let error { throw error }
        return result
    }
}
