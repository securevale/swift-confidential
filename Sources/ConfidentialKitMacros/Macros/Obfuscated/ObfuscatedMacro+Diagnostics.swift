import SwiftDiagnostics
import SwiftSyntax

extension ObfuscatedMacro {

    enum DiagnosticErrors {

        private typealias DiagnosticMessage = MacroExpansionDiagnosticMessage<Self>

        static func macroCanOnlyBeAttachedToVariableDeclaration(node: some SyntaxProtocol) -> some Error {
            DiagnosticsError(
                node: node,
                message: DiagnosticMessage(
                    message: "'@Obfuscated' can only be attached to a variable declaration",
                    severity: .error
                )
            )
        }

        static func macroDoesNotSupportClosureExpressions(
            node: some SyntaxProtocol,
            highlight: some SyntaxProtocol
        ) -> some Error {
            DiagnosticsError(
                node: node,
                message: DiagnosticMessage(
                    message: """
                    '@Obfuscated' does not support closure expressions, use function reference instead
                    """,
                    severity: .error
                ),
                highlights: [Syntax(highlight)]
            )
        }

        static func macroMissingArgumentForParameter(at position: Int, node: some SyntaxProtocol) -> some Error {
            DiagnosticsError(
                node: node,
                message: DiagnosticMessage(
                    message: "Missing argument for parameter #\(position) in macro expansion",
                    severity: .error
                )
            )
        }

        static func macroMissingGenericParameter(named name: String, node: some SyntaxProtocol) -> some Error {
            DiagnosticsError(
                node: node,
                message: DiagnosticMessage(
                    message: "Generic parameter '\(name)' could not be inferred",
                    severity: .error
                )
            )
        }

        static func secretVariableDeclarationMustHaveValidIdentifier(node: some SyntaxProtocol) -> some Error {
            DiagnosticsError(
                node: node,
                message: DiagnosticMessage(
                    message: "Secret variable declaration must have a valid identifier",
                    severity: .error
                )
            )
        }
    }
}

extension ObfuscatedMacro.DiagnosticErrors: DiagnosticMessageDomain {

    static func diagnosticID(for messageID: String) -> MessageID {
        .init(domain: "\(ObfuscatedMacro.self)", id: "\(self).\(messageID)")
    }
}
