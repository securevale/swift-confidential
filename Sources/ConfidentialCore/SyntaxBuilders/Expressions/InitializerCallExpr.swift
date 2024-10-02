import SwiftSyntax
import SwiftSyntaxBuilder

extension FunctionCallExprSyntax {

    static func makeInitializerCallExpr(
        @LabeledExprListBuilder argumentListBuilder: () -> LabeledExprListSyntax = {
            LabeledExprListSyntax([])
        }
    ) -> Self {
        .init(
            calledExpression: MemberAccessExprSyntax(
                declName: .init(baseName: .keyword(.`init`))
            ),
            leftParen: .leftParenToken(),
            arguments: argumentListBuilder(),
            rightParen: .rightParenToken()
        )
    }
}
