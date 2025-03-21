import Foundation

/// A property wrapper that can deobfuscate the wrapped secret value.
@propertyWrapper
public struct Obfuscated<PlainValue: Decodable & Sendable> {

    /// A type that represents a wrapped value.
    public typealias Value = Obfuscation.Secret

    /// A type that represents a deobfuscation function.
    public typealias DeobfuscateDataFunc = (Data, Obfuscation.Nonce) throws -> Data

    @usableFromInline
    let deobfuscateData: DeobfuscateDataFunc

    @usableFromInline
    let decoder: any DataDecoder

    /// The underlying secret value.
    public let wrappedValue: Value

    /// A plain secret value after transforming obfuscated secret's data with a deobfuscation function.
    @inlinable
    public var projectedValue: PlainValue {
        let data = Data(wrappedValue.data)
        let nonce = wrappedValue.nonce
        let value: PlainValue

        do {
            let deobfuscatedData = try deobfuscateData(data, nonce)
            value = try decoder.decode(PlainValue.self, from: deobfuscatedData)
        } catch {
            preconditionFailure("Unexpected error: \(error)")
        }

        return value
    }

    @usableFromInline
    init(
        wrappedValue: Value,
        deobfuscateData: @escaping DeobfuscateDataFunc,
        decoder: any DataDecoder
    ) {
        self.wrappedValue = wrappedValue
        self.deobfuscateData = deobfuscateData
        self.decoder = decoder
    }

    /// Creates a property that can deobfuscate the wrapped secret value using the given closure.
    ///
    /// - Parameters:
    ///   - wrappedValue: A secret value containing obfuscated data.
    ///   - deobfuscateData: The closure to execute when calling ``projectedValue``.
    @inlinable
    public init(
        wrappedValue: Value,
        _ deobfuscateData: @escaping DeobfuscateDataFunc
    ) {
        self.init(
            wrappedValue: wrappedValue,
            deobfuscateData: deobfuscateData,
            decoder: JSONDecoder()
        )
    }
}
