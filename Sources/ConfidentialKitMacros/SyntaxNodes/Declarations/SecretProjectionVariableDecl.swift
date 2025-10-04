import SwiftSyntax

extension VariableDeclSyntax {

    static func makeSecretProjectionVariableDecl(
        modifiers: DeclModifierListSyntax,
        secretIdentifier: TokenSyntax,
        type: TypeSyntax,
        deobfuscateDataArgument: ObfuscatedMacro.DeobfuscateDataArgument
    ) -> Self {
        .init(
            modifiers: modifiers,
            .var,
            name: "$\(secretIdentifier.text)",
            type: type,
            accessors: .getter(
                CodeBlockItemListSyntax {
                    secretDataVariableDecl(referencing: secretIdentifier)
                    nonceVariableDecl(referencing: secretIdentifier)
                    valueVariableDecl(of: type)
                    DoStmtSyntax(
                        catchClauses: CatchClauseListSyntax {
                            catchClause()
                        }
                    ) {
                        deobfuscatedDataVariableDecl(referencing: deobfuscateDataArgument)
                        valueAssignmentExpr(referencing: type)
                    }
                    returnStmt()
                }
            )
        )
    }
}

private extension VariableDeclSyntax {

    static let deobfuscatedDataVariableName: String = "deobfuscatedData"
    static let secretDataVariableName: String = "data"
    static let secretNonceVariableName: String = "nonce"
    static let valueVariableName: String = "value"

    static func secretDataVariableDecl(referencing secretIdentifier: TokenSyntax) -> Self {
        .init(
            .let,
            name: secretDataVariableName,
            initializer: .init(
                value: FunctionCallExprSyntax(
                    callee: DeclReferenceExprSyntax(
                        baseName: .identifier("Data")
                    )
                ) {
                    LabeledExprSyntax(
                        expression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(
                                baseName: secretIdentifier
                            ),
                            name: .identifier(secretDataVariableName)
                        )
                    )
                }
            )
        )
    }

    static func nonceVariableDecl(referencing secretIdentifier: TokenSyntax) -> Self {
        .init(
            .let,
            name: secretNonceVariableName,
            initializer: .init(
                value: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(
                        baseName: secretIdentifier
                    ),
                    name: .identifier(secretNonceVariableName)
                )
            )
        )
    }

    static func valueVariableDecl(of type: TypeSyntax) -> Self {
        .init(
            .let,
            name: valueVariableName,
            type: type
        )
    }

    static func deobfuscatedDataVariableDecl(
        referencing deobfuscateDataArgument: ObfuscatedMacro.DeobfuscateDataArgument
    ) -> Self {
        let callee: any ExprSyntaxProtocol
        let argumentLabels: (TokenSyntax, TokenSyntax)
        switch deobfuscateDataArgument {
        case let .closure(closureExpr):
            callee = closureExpr
            argumentLabels = (.wildcardToken(), .wildcardToken())
        case let .functionReference(name, argLabels):
            callee = DeclReferenceExprSyntax(baseName: name)
            argumentLabels = argLabels
        }

        return .init(
            .let,
            name: deobfuscatedDataVariableName,
            initializer: .init(
                value: TryExprSyntax(
                    expression: FunctionCallExprSyntax(
                        callee: callee
                    ) {
                        labeledExpr(
                            label: argumentLabels.0,
                            expression: DeclReferenceExprSyntax(
                                baseName: .identifier(secretDataVariableName)
                            )
                        )
                        labeledExpr(
                            label: argumentLabels.1,
                            expression: DeclReferenceExprSyntax(
                                baseName: .identifier(secretNonceVariableName)
                            )
                        )
                    }
                )
            )
        )
    }

    static func valueAssignmentExpr(referencing type: TypeSyntax) -> InfixOperatorExprSyntax {
        .init(
            leftOperand: DeclReferenceExprSyntax(baseName: .identifier(valueVariableName)),
            operator: AssignmentExprSyntax(),
            rightOperand: TryExprSyntax(
                expression: FunctionCallExprSyntax(
                    callee: MemberAccessExprSyntax(
                        base: FunctionCallExprSyntax(
                            callee: DeclReferenceExprSyntax(
                                baseName: .identifier("JSONDecoder")
                            )
                        ),
                        name: .identifier("decode")
                    )
                ) {
                    LabeledExprSyntax(
                        expression: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(
                                baseName: .identifier(String(describing: type))
                            ),
                            period: .periodToken(),
                            name: .keyword(.`self`)
                        )
                    )
                    LabeledExprSyntax(
                        label: "from",
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier(deobfuscatedDataVariableName)
                        )
                    )
                }
            )
        )
    }

    static func returnStmt() -> ReturnStmtSyntax {
        .init(
            expression: DeclReferenceExprSyntax(
                baseName: .identifier(valueVariableName)
            )
        )
    }
}

private extension VariableDeclSyntax {

    static func catchClause() -> CatchClauseSyntax {
        .init {
            FunctionCallExprSyntax.makePreconditionFailureFunctionCallExpr(
                message: StringLiteralExprSyntax(
                    openingQuote: .stringQuoteToken(),
                    segments: .init {
                        StringSegmentSyntax(
                            content: "Unexpected error:"
                        )
                        ExpressionSegmentSyntax(
                            expressions: .init {
                                LabeledExprSyntax(
                                    expression: DeclReferenceExprSyntax(
                                        baseName: .identifier("error")
                                    )
                                )
                            }
                        )
                    },
                    closingQuote: .stringQuoteToken()
                )
            )
        }
    }
}

private extension VariableDeclSyntax {

    static func labeledExpr(
        label: TokenSyntax,
        expression: some ExprSyntaxProtocol
    ) -> LabeledExprSyntax {
        if label.isWildcardToken {
            .init(
                expression: expression
            )
        } else {
            .init(
                label: label,
                colon: .colonToken(trailingTrivia: .space),
                expression: expression
            )
        }
    }
}
