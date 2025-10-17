#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ConfidentialCompilerPlugin: CompilerPlugin {

    let providingMacros: [Macro.Type] = [
        ObfuscateMacro.self,
        ObfuscatedMacro.self
    ]
}
#endif
