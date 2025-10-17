import ConfidentialCore
import ConfidentialUtils
import SwiftSyntax

extension FunctionCallExprSyntax {

    static func makeDataShufflerInitializerCallExpr() -> Self {
        .init(
            callee: DeclReferenceExprSyntax(
                baseName: .identifier(
                    TypeInfo(of: Obfuscation.Randomization.DataShuffler.self).fullyQualifiedName
                )
            )
        )
    }
}
