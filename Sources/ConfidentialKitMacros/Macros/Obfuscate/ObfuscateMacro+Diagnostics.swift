import SwiftDiagnostics
import SwiftSyntax

extension ObfuscateMacro {

    enum DiagnosticErrors {

        private typealias DiagnosticMessage = MacroExpansionDiagnosticMessage<Self>

        static func macroMissingArgumentForParameter(at position: Int, node: some SyntaxProtocol) -> DiagnosticsError {
            DiagnosticsError(
                node: node,
                message: DiagnosticMessage(
                    message: "Missing argument for parameter #\(position) in macro expansion",
                    severity: .error
                )
            )
        }

        static func macroInvalidOrMalformedArgumentForParameter(
            at position: Int,
            node: some SyntaxProtocol
        ) -> DiagnosticsError {
            DiagnosticsError(
                node: node,
                message: DiagnosticMessage(
                    message: "Invalid or malformed argument for parameter #\(position) in macro expansion",
                    severity: .error
                )
            )
        }

        static func customAlgorithmMustIncludeAtLeastOneObfuscationStep(
            node: some SyntaxProtocol
        ) -> DiagnosticsError {
            DiagnosticsError(
                node: node,
                message: DiagnosticMessage(
                    message: "Custom algorithm must include at least one obfuscation step",
                    severity: .error
                )
            )
        }

        static func macroExpectsVariableDeclarationsOfSupportedTypes(
            node: some SyntaxProtocol,
            highlight: some SyntaxProtocol
        ) -> DiagnosticsError {
            DiagnosticsError(
                node: node,
                message: DiagnosticMessage(
                    message: "'#Obfuscate' expects variable declarations of type 'String' or 'Array<String>'",
                    severity: .error
                ),
                highlights: [Syntax(highlight)]
            )
        }

        static func variableDeclarationMustHaveValidIdentifier(node: some SyntaxProtocol) -> DiagnosticsError {
            DiagnosticsError(
                node: node,
                message: DiagnosticMessage(
                    message: "Variable declaration must have a valid identifier",
                    severity: .error
                )
            )
        }

        static func variableMustBeAssignedLiteralOfSupportedType(
            variableName: String,
            node: some SyntaxProtocol
        ) -> DiagnosticsError {
            DiagnosticsError(
                node: node,
                message: DiagnosticMessage(
                    message: "'\(variableName)' must be assigned a literal of type 'String' or 'Array<String>'",
                    severity: .error
                )
            )
        }

        static func variableValueMustBeCompileTimeConstantOfSupportedType(
            variableName: String,
            node: some SyntaxProtocol
        ) -> DiagnosticsError {
            DiagnosticsError(
                node: node,
                message: DiagnosticMessage(
                    message: """
                    '\(variableName)' value must be a compile-time constant of type 'String' or 'Array<String>'
                    """,
                    severity: .error
                )
            )
        }
    }
}

extension ObfuscateMacro.DiagnosticErrors: DiagnosticMessageDomain {

    static func diagnosticID(for messageID: String) -> MessageID {
        .init(domain: "\(ObfuscateMacro.self)", id: "\(self).\(messageID)")
    }
}
