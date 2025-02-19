#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ConfidentialCompilerPlugin: CompilerPlugin {

    let providingMacros: [Macro.Type] = [
        ObfuscatedMacro.self
    ]
}
#endif
