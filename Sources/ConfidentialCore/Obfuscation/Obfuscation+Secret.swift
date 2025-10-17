public extension Obfuscation {

    /// A model representing an obfuscated secret.
    struct Secret: Equatable, Sendable {

        /// The obfuscated secret's bytes.
        public var data: [UInt8]

        /// The nonce used during the obfuscation process of this secret.
        public let nonce: Nonce

        /// Creates a new instance from the given sequence containing obfuscated secret's bytes and
        /// associated nonce.
        ///
        /// - Parameter data: The sequence of obfuscated secret's bytes.
        /// - Parameter nonce: The nonce associated with the obfuscated secret's bytes.
        public init<Data: Sequence>(data: Data, nonce: Nonce) where Data.Element == UInt8 {
            self.data = .init(data)
            self.nonce = nonce
        }
    }
}
