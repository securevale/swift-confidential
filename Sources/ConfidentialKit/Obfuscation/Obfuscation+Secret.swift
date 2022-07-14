public extension Obfuscation {

    /// A model representing an obfuscated secret.
    struct Secret: Equatable {

        /// The obfuscated secret's bytes.
        public let data: [UInt8]

        /// Creates a new instance of a sequence containing obfuscated secret's bytes.
        /// 
        /// - Parameter data: The sequence of obfuscated secret's bytes.
        @inlinable
        public init<Data: Sequence>(data: Data) where Data.Element == UInt8 {
            self.data = .init(data)
        }
    }
}
