extension Configuration.Secret.Value {

    var underlyingValue: AnyEncodable {
        switch self {
        case let .array(value):
            return value.eraseToAnyEncodable()
        case let .singleValue(value):
            return value.eraseToAnyEncodable()
        }
    }
}
