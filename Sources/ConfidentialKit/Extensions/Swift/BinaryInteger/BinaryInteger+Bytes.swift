public extension BinaryInteger {

    /// This value's binary representation, as a sequence of contiguous bytes.
    @inlinable
    @inline(__always)
    var bytes: [UInt8] { withUnsafeBytes(of: self, [UInt8].init) }

    /// Creates a new instance from the given binary representation.
    /// 
    /// - Parameter bytes: A collection containing the bytes of this value’s binary representation,
    ///   in order from the least significant to most significant.
    @inlinable
    @inline(__always)
    init<Bytes: Collection>(bytes: Bytes) where Bytes.Element == UInt8 {
        var bytes = Array<Bytes.Element>(bytes)
        let size = MemoryLayout<Self>.stride
        if bytes.count < size {
            bytes.append(contentsOf: (bytes.count..<size).map { _ in .zero })
        }

        self = bytes.withUnsafeBytes { $0.load(as: Self.self) }
    }
}
