import SwiftDiagnostics
import SwiftSyntax

protocol DiagnosticMessageDomain: Sendable {
    static func diagnosticID(for messageID: String) -> MessageID
}

struct MacroExpansionDiagnosticMessage<Domain>: DiagnosticMessage where Domain: DiagnosticMessageDomain {

    let message: String

    var diagnosticID: MessageID { Domain.diagnosticID(for: messageID) }

    let severity: DiagnosticSeverity

    private let messageID: String

    init(message: String, messageID: String = #function, severity: DiagnosticSeverity) {
        self.message = message
        self.messageID = messageID
        self.severity = severity
    }
}

extension DiagnosticsError {

    init(
     node: some SyntaxProtocol,
     position: AbsolutePosition? = nil,
     message: some DiagnosticMessage,
     highlights: [Syntax]? = nil,
     notes: [Note] = [],
     fixIts: [FixIt] = []
    ) {
        self.init(
            diagnostics: [
                Diagnostic(
                    node: node,
                    position: position,
                    message: message,
                    highlights: highlights,
                    notes: notes,
                    fixIts: fixIts
                )
            ]
        )
    }
}
