/// A namespace for types associated with obfuscation-related tasks, which all together
/// constitute an API for (de)obfuscating secret data.
///
/// The various implementations of obfuscation techniques are defined within their own
/// namespaces defined as extensions on ``Obfuscation``.
///
/// Your choice of technique determines the strategy used for data obfuscation:
///   - The ``Obfuscation/Compression`` namespace encapsulates
///     implementations of technique involving data compression/decompression.
///   - The ``Obfuscation/Encryption`` namespace encapsulates
///     implementations of technique involving data encryption/decryption.
///   - The ``Obfuscation/Randomization`` namespace encapsulates
///     implementations of technique involving data randomization.
///
/// > Important: The ``ConfidentialKit`` library was designed to be used in
///          conjunction with `swift-confidential` CLI tool and, as such, it
///          only ships with a subset of API needed for deobfuscating obfuscated
///          secret data embedded in the application code.
public enum Obfuscation {}
