import Foundation

/// A type that can deobfuscate the data for further processing.
///
/// The instances of types conforming to ``DataDeobfuscationStep`` can be composed
/// together to form a deobfuscation algorithm.
public protocol DataDeobfuscationStep {
    /// Deobfuscates the given data using operations that reverse the obfuscation process.
    ///
    /// - Parameter data: An obfuscated input data.
    /// - Parameter nonce: A nonce used during the deobfuscation process.
    /// - Returns: A deobfuscated output data.
    func deobfuscate(_ data: Data, nonce: Obfuscation.Nonce) throws -> Data
}
