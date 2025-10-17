struct HexEncodingOptions: OptionSet {
    static let upperCase: Self = .init(rawValue: 1 << 0)
    static let numericLiteral: Self = .init(rawValue: 1 << 1)

    let rawValue: Int
}

extension Sequence where Element == UInt8 {

    func hexEncodedStringComponents(options: HexEncodingOptions = []) -> [String] {
        var format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        if options.contains(.numericLiteral) {
            format = "0x\(format)"
        }

        return map { String(format: format, $0) }
    }
}
