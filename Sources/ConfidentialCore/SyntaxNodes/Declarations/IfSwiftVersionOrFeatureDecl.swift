import SwiftSyntax

extension IfConfigDeclSyntax {

    static func makeIfSwiftVersionOrFeatureDecl(
        swiftVersion: Float,
        featureFlag: String,
        ifElements: IfConfigClauseSyntax.Elements,
        elseElements: IfConfigClauseSyntax.Elements
    ) -> Self {
        .init(
            clauses: IfConfigClauseListSyntax {
                IfConfigClauseSyntax(
                    poundKeyword: .poundIfToken(),
                    condition: InfixOperatorExprSyntax(
                        leftOperand: compilerFunctionCallExpr(
                            prefixOperator: ">=",
                            swiftVersion: swiftVersion
                        ),
                        operator: BinaryOperatorExprSyntax(
                            operator: .binaryOperator("||")
                        ),
                        rightOperand: hasFeatureFunctionCallExpr(
                            featureFlag: featureFlag
                        )
                    ),
                    elements: ifElements
                )
                IfConfigClauseSyntax(
                    poundKeyword: .poundElseToken(),
                    elements: elseElements
                )
            }
        )
    }
}

private extension IfConfigDeclSyntax {

    static func compilerFunctionCallExpr(prefixOperator: String, swiftVersion: Float) -> FunctionCallExprSyntax {
        .init(
            callee: DeclReferenceExprSyntax(
                baseName: .identifier("compiler")
            )
        ) {
            LabeledExprSyntax(
                expression: PrefixOperatorExprSyntax(
                    operator: .prefixOperator(">="),
                    expression: FloatLiteralExprSyntax(swiftVersion)
                )
            )
        }
    }

    static func hasFeatureFunctionCallExpr(featureFlag: String) -> FunctionCallExprSyntax {
        .init(
            callee: DeclReferenceExprSyntax(
                baseName: .identifier("hasFeature")
            )
        ) {
            LabeledExprSyntax(
                expression: DeclReferenceExprSyntax(
                    baseName: .identifier(featureFlag)
                )
            )
        }
    }
}
