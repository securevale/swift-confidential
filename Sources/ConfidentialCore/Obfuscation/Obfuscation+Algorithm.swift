public extension Obfuscation {

    /// A specifier that describes the obfuscation algorithm properties.
    enum AlgorithmSpecifier: Hashable, Sendable {
        /// Use custom obfuscation algorithm.
        case custom(Algorithm)

        /// Use randomly generated obfuscation algorithm.
        case random
    }
}

public extension Obfuscation {

    /// A type that represents an obfuscation algorithm.
    typealias Algorithm = Array<Step>

    /// An obfuscation step that indicates how to obfuscate or deobfuscate secret data.
    ///
    /// When composed together, the obfuscation steps form an obfuscation algorithm.
    ///
    /// ```swift
    /// let algorithm: Obfuscation.Algorithm = [.encrypt(algorithm: .aes192GCM), .shuffle]
    /// ```
    enum Step: Hashable, Sendable {
        /// Apply data compression using the given algorithm.
        case compress(algorithm: Obfuscation.Compression.CompressionAlgorithm)

        /// Apply data encryption using the given algorithm.
        case encrypt(algorithm: Obfuscation.Encryption.SymmetricEncryptionAlgorithm)

        /// Apply data randomization.
        case shuffle
    }
}
