import Foundation

/// Creates a projection variable that exposes a plain secret value.
///
/// The generated projection variable returns a plain secret value after transforming obfuscated
/// secret’s data using the given `deobfuscateData` closure and JSON decoding the
/// data into a value of the type specified by the `PlainValue` generic argument.
///
/// - Note: You can also pass a reference to the `deobfuscateData` function.
///         If you omit the argument labels, then the default `(_:nonce:)` will be used.
///
/// The name of the projection variable is the same as the variable to which the macro is attached,
/// except it begins with a dollar sign ($).
///
/// - Important: This macro is only meant to be attached to variables of type
///              ``/ConfidentialKit/Obfuscation/Secret``.
///
/// - Parameter deobfuscateData: A closure that takes an obfuscated secret’s data and its
///                              corresponding nonce as arguments, and returns the
///                              deobfuscated data.
@attached(peer, names: prefixed(`$`))
public macro Obfuscated<PlainValue: Decodable & Sendable>(
    _ deobfuscateData: (Data, Obfuscation.Nonce) throws -> Data
)
= #externalMacro(module: "ConfidentialKitMacros", type: "ObfuscatedMacro")
