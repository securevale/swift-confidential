final class ParameterlessClosureSpy<Result> {

    var result: Result
    var error: Error?

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
        if let error = error { throw error }
        return result
    }
}
