import ConfidentialKit
import Foundation

/// Creates a projection variable that exposes a plain secret value.
///
/// The generated projection variable returns a plain secret value after transforming obfuscated
/// secret’s data using the specified `deobfuscateData`  function and JSON decoding the
/// data into a value of the type specified by the `PlainValue` generic argument.
///
/// The name of the projection variable is the same as the variable to which the macro is attached,
/// except it begins with a dollar sign ($).
///
/// - Important: This macro is only meant to be attached to variables of type
///              ``/ConfidentialKit/Obfuscation/Secret``.
///
/// - Parameter deobfuscateData: A reference to the deobfuscation function. If you omit
///                              the argument labels, then the default `(_:nonce:)`
///                              will be used. Note that closure expressions are not
///                              supported.
@attached(peer, names: prefixed(`$`))
public macro Obfuscated<PlainValue: Decodable & Sendable>(
    _ deobfuscateData: (Data, Obfuscation.Nonce) throws -> Data
)
= #externalMacro(module: "ConfidentialKitMacros", type: "ObfuscatedMacro")
