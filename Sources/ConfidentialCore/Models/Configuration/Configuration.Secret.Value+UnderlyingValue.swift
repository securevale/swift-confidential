extension Configuration.Secret.Value {

    var underlyingValue: AnyEncodable {
        switch self {
        case let .array(value): value.eraseToAnyEncodable()
        case let .singleValue(value): value.eraseToAnyEncodable()
        }
    }
}
