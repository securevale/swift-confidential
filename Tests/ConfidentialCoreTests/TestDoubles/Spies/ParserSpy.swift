import Parsing

final class ParserSpy<Input, Output>: Parser {

    var result: Output
    var consumeInput: ((inout Input) throws -> Void)?

    private(set) var parseRecordedInput: [Input] = []

    init(result: Output) {
        self.result = result
    }

    func parse(_ input: inout Input) throws -> Output {
        parseRecordedInput.append(input)
        try consumeInput?(&input)
        return result
    }
}
