import ConfidentialKit
import SwiftSyntax
import SwiftSyntaxBuilder

struct DataShufflerInitializerCallExpr: ExprBuildable {

    private let nonce: UInt64

    init(nonce: UInt64) {
        self.nonce = nonce
    }

    func buildExpr(format: Format, leadingTrivia: Trivia?) -> ExprSyntax {
        makeUnderlyingExpr().buildExpr(format: format, leadingTrivia: leadingTrivia)
    }
}

private extension DataShufflerInitializerCallExpr {

    static let nonceArgumentName: String = "nonce"

    func makeUnderlyingExpr() -> ExprBuildable {
        FunctionCallExpr(
            IdentifierExpr(
                TypeInfo(of: Obfuscation.Randomization.DataShuffler.self).fullyQualifiedName
            ),
            leftParen: .leftParen,
            rightParen: .rightParen,
            argumentListBuilder: {
                TupleExprElement(
                    label: .identifier(Self.nonceArgumentName),
                    colon: .colon,
                    expression: IntegerLiteralExpr(digits: "\(nonce)")
                )
            }
        )
    }
}
