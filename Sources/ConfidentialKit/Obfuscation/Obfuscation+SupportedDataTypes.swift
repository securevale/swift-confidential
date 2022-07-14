public extension Obfuscation {

    /// A namespace for the plain data types supported by ``Obfuscation`` API.
    enum SupportedDataTypes {
        /// A type that represents a sequence of values.
        public typealias Array = [String]

        /// A type that represents a single value.
        public typealias SingleValue = String
    }
}
