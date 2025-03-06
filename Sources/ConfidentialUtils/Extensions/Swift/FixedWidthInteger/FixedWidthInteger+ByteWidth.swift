package extension FixedWidthInteger {

    /// The number of bytes used for the underlying binary representation of
    /// values of this type.
    @inlinable
    @inline(__always)
    static var byteWidth: Int { (bitWidth + 7) / 8 }
}
