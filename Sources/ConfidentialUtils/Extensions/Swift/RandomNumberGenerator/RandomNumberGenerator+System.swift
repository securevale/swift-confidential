package extension RandomNumberGenerator where Self == SystemRandomNumberGenerator {

    /// An instance of the system's default random number generator.
    @inlinable
    @inline(__always)
    static var system: Self { .init() }
}
