import SwiftSyntax

extension FunctionCallExprSyntax {

    static func makePreconditionFailureFunctionCallExpr(
        message: StringLiteralExprSyntax
    ) -> Self {
        .init(
            callee: DeclReferenceExprSyntax(
                baseName: .identifier("preconditionFailure")
            )
        ) {
            LabeledExprSyntax(
                expression: message
            )
        }
    }
}
