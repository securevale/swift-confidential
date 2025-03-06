import ConfidentialKit
import ConfidentialUtils
import SwiftSyntax

extension FunctionCallExprSyntax {

    static func makeDataShufflerInitializerCallExpr() -> Self {
        .init(
            calledExpression: DeclReferenceExprSyntax(
                baseName: .identifier(
                    TypeInfo(of: Obfuscation.Randomization.DataShuffler.self).fullyQualifiedName
                )
            ),
            leftParen: .leftParenToken(),
            arguments: [],
            rightParen: .rightParenToken()
        )
    }
}
