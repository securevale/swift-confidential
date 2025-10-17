/// Creates the obfuscated secret declarations.
///
/// Use this macro to obfuscate code literals that you want to protect against static code analysis.
/// 
/// ```swift
/// enum ObfuscatedLiterals {
///     static #Obfuscate {
///         let apiKey = "214C1E2E-A87E-4460-8205-4562FDF54D1C"
///     }
/// }
/// ```
///
/// You can then reference a deobfuscated code literal using the projected value of the generated
/// secret declaration.
///
/// ```swift
/// let events = try await fetchEvents(apiKey: ObfuscatedLiterals.$apiKey)
/// ```
///
/// By default, the ``Obfuscate(algorithm:declarations:)`` macro generates a random obfuscation
/// algorithm for each secret. You can, however, specify your own obfuscation algorithm to be
/// applied to all secrets.
///
/// ```swift
/// extension ObfuscatedLiterals {
///     static #Obfuscate(algorithm: .custom([.encrypt(algorithm: .aes192GCM), .shuffle])) {
///         let trustedSPKIDigests = [
///             "7a6820614ee600bbaed493522c221c0d9095f3b4d7839415ffab16cbf61767ad",
///             "cf84a70a41072a42d0f25580b5cb54d6a9de45db824bbb7ba85d541b099fd49f",
///             "c1a5d45809269301993d028313a5c4a5d8b2f56de9725d4d1af9da1ccf186f30"
///         ]
///     }
/// }
/// ```
///
///  - Warning: The obfuscation algorithm from the above code snippet serves as example only.
///             **For production use, always compose your own algorithm and do not share it with
///             anyone.**
///
/// Note how the macro expansion attributes and modifiers, such as `@usableFromInline` and `static`,
/// are copied to expanded secret declarations.
///
/// - Important: You cannot use ``Obfuscate(algorithm:declarations:)`` macro at global scope.
///              This aligns with the recommended practice of encapsulating secret declarations
///              within namespaces, such as caseless enums.
///
/// - Parameter algorithm: An obfuscation algorithm for obfuscating the secret literals extracted
///                        from the given declarations. Default value is
///                        ``/ConfidentialCore/Obfuscation/AlgorithmSpecifier/random``.
/// - Parameter declarations: A closure that contains the declarations of constants or variables
///                           defining each secret's identifier and its corresponding plaintext
///                           value to be obfuscated. The plaintext value must be a literal of type
///                           `String` or `Array<String>`.
@freestanding(declaration, names: arbitrary)
public macro Obfuscate(
    algorithm: Obfuscation.AlgorithmSpecifier = .random,
    declarations: () -> Void
)
= #externalMacro(module: "ConfidentialKitMacros", type: "ObfuscateMacro")
