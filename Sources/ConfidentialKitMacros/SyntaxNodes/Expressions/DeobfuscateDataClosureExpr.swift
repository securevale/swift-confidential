import ConfidentialCore
import SwiftSyntax

extension ClosureExprSyntax {

    private static let dataParameterName: String = "data"
    private static let nonceParameterName: String = "nonce"

    static func makeDeobfuscateDataClosureExpr(algorithm: Obfuscation.Algorithm) -> Self {
        .init(
            signature: ClosureSignatureSyntax(
                parameterClause: .simpleInput(
                    .init {
                        ClosureShorthandParameterSyntax(
                            name: .identifier(Self.dataParameterName),
                            trailingComma: .commaToken(trailingTrivia: .space)
                        )
                        ClosureShorthandParameterSyntax(
                            name: .identifier(Self.nonceParameterName, trailingTrivia: .space)
                        )
                    }
                )
            )
        ) {
            CodeBlockItemSyntax(
                item: .init(bodyExpr(applying: algorithm))
            )
        }
    }
}

private extension ClosureExprSyntax {

    static func bodyExpr(applying algorithm: Obfuscation.Algorithm) -> some ExprSyntaxProtocol {
        assert(!algorithm.isEmpty)
        var obfuscationStepsCount = algorithm.count
        let innerMostObfuscationStep = obfuscationStepExpr(
            for: algorithm[algorithm.startIndex],
            indentWidthMultiplier: obfuscationStepsCount
        )
        let expression = algorithm
            .dropFirst()
            .reduce(innerMostObfuscationStep) { innerExpr, step in
                obfuscationStepsCount -= 1
                return obfuscationStepExpr(
                    for: step,
                    withInnerExpr: innerExpr,
                    indentWidthMultiplier: obfuscationStepsCount
                )
            }

        return expression
    }
}

private extension ClosureExprSyntax {

    static let deobfuscateFunctionName: String = "deobfuscate"
    static let nonceArgumentLabel: String = "nonce"

    static func obfuscationStepExpr(
        for obfuscationStep: Obfuscation.Step,
        indentWidthMultiplier: Int
    ) -> TryExprSyntax {
        let tryIndentWidth = exprIndentWidth(with: indentWidthMultiplier)
        let functionCallExprIndentWidth = tryIndentWidth + C.Code.Format.indentWidth
        return TryExprSyntax(
            tryKeyword: .keyword(.try, leadingTrivia: tryIndentWidth, trailingTrivia: .space),
            expression: FunctionCallExprSyntax(
                calledExpression: deobfuscateFunctionAccessExpr(
                    for: obfuscationStep,
                    indentWidth: functionCallExprIndentWidth
                ),
                leftParen: .leftParenToken(),
                arguments: .init {
                    LabeledExprSyntax(
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier(dataParameterName)
                        ),
                        trailingComma: .commaToken()
                    )
                    LabeledExprSyntax(
                        label: .identifier(nonceArgumentLabel),
                        colon: .colonToken(),
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier(nonceParameterName)
                        )
                    )
                },
                rightParen: .rightParenToken()
            )
        )
    }

    static func obfuscationStepExpr(
        for obfuscationStep: Obfuscation.Step,
        withInnerExpr innerExpr: some ExprSyntaxProtocol,
        indentWidthMultiplier: Int
    ) -> TryExprSyntax {
        let tryIndentWidth = exprIndentWidth(with: indentWidthMultiplier)
        let functionCallExprIndentWidth = tryIndentWidth + C.Code.Format.indentWidth
        let functionCallExprArgumentIndentWidth = functionCallExprIndentWidth + C.Code.Format.indentWidth
        return TryExprSyntax(
            tryKeyword: .keyword(.try, leadingTrivia: tryIndentWidth, trailingTrivia: .space),
            expression: FunctionCallExprSyntax(
                calledExpression: deobfuscateFunctionAccessExpr(
                    for: obfuscationStep,
                    indentWidth: functionCallExprIndentWidth
                ),
                leftParen: .leftParenToken(trailingTrivia: .newlines(1)),
                arguments: .init {
                    LabeledExprSyntax(
                        expression: innerExpr,
                        trailingComma: .commaToken()
                    )
                    LabeledExprSyntax(
                        label: .identifier(nonceArgumentLabel)
                            .with(
                                \.leadingTrivia,
                                .newline
                                .appending(functionCallExprArgumentIndentWidth)
                            ),
                        colon: .colonToken(),
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier(nonceParameterName)
                        )
                    )
                },
                rightParen: .rightParenToken()
                    .with(
                        \.leadingTrivia,
                        .newline
                        .appending(functionCallExprIndentWidth)
                    )
            )
        )
    }

    static func deobfuscateFunctionAccessExpr(
        for obfuscationStep: Obfuscation.Step,
        indentWidth: Trivia
    ) -> some ExprSyntaxProtocol {
        let initCallExpr: FunctionCallExprSyntax
        switch obfuscationStep {
        case let .compress(algorithm):
            initCallExpr = FunctionCallExprSyntax.makeDataCompressorInitializerCallExpr(algorithm: algorithm)
        case let .encrypt(algorithm):
            initCallExpr = FunctionCallExprSyntax.makeDataCrypterInitializerCallExpr(algorithm: algorithm)
        case .shuffle:
            initCallExpr = FunctionCallExprSyntax.makeDataShufflerInitializerCallExpr()
        }

        return MemberAccessExprSyntax(
            base: initCallExpr,
            period: .periodToken()
                .with(
                    \.leadingTrivia,
                    .newline
                    .appending(indentWidth)
                ),
            declName: .init(baseName: .identifier(deobfuscateFunctionName))
        )
    }
}

private extension ClosureExprSyntax {

    static func exprIndentWidth(with indentWidthMultiplier: Int) -> Trivia {
        let indentWidthMultiplier = max(indentWidthMultiplier, 1)
        let multiplier = 1 + (indentWidthMultiplier - 1) * 2

        return Trivia(
            pieces: Array(
                repeating: C.Code.Format.indentWidth.pieces,
                count: multiplier
            )
            .flatMap { $0 }
        )
    }
}
