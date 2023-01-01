import ConfidentialKit
import SwiftSyntax
import SwiftSyntaxBuilder

struct DataShufflerInitializerCallExpr: ExprBuildable {

    func buildExpr(format: Format, leadingTrivia: Trivia?) -> ExprSyntax {
        makeUnderlyingExpr().buildExpr(format: format, leadingTrivia: leadingTrivia)
    }
}

private extension DataShufflerInitializerCallExpr {

    func makeUnderlyingExpr() -> ExprBuildable {
        FunctionCallExpr(
            IdentifierExpr(
                TypeInfo(of: Obfuscation.Randomization.DataShuffler.self).fullyQualifiedName
            ),
            leftParen: .leftParen,
            rightParen: .rightParen
        )
    }
}
