enum ParsingError: Error {
    case assertionFailed(description: String)
}

extension ParsingError: CustomStringConvertible {

    var description: String {
        switch self {
        case let .assertionFailed(description): description
        }
    }
}
