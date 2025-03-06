import Parsing
import SwiftSyntax

struct DeobfuscateDataFunctionDeclParser: Parser {

    typealias Algorithm = SourceFileSpec.Algorithm

    private let functionNestingLevel: Int

    init(functionNestingLevel: Int) {
        self.functionNestingLevel = functionNestingLevel
    }

    func parse(_ input: inout Algorithm) throws -> any DeclSyntaxProtocol {
        var obfuscationStepsCount = input.count
        guard obfuscationStepsCount > .zero else {
            throw ParsingError.assertionFailed(
                description: "Obfuscation algorithm must consist of at least one obfuscation step."
            )
        }

        let reversedAlgorithm = input.reversed()
        let innerMostObfuscationStep = try obfuscationStepExpr(
            for: reversedAlgorithm[reversedAlgorithm.startIndex],
            indentWidthMultiplier: obfuscationStepsCount
        )
        let bodyExpr = try reversedAlgorithm
            .dropFirst()
            .reduce(innerMostObfuscationStep) { innerExpr, step in
                obfuscationStepsCount -= 1
                return try obfuscationStepExpr(
                    for: step,
                    withInnerExpr: innerExpr,
                    indentWidthMultiplier: obfuscationStepsCount
                )
            }

        input.removeAll()

        return FunctionDeclSyntax.makeDeobfuscateDataFunctionDecl(
            nestingLevel: functionNestingLevel,
            body: bodyExpr
        )
    }
}

private extension DeobfuscateDataFunctionDeclParser {

    typealias ObfuscationStep = SourceFileSpec.ObfuscationStep

    static let nonceArgumentName: String = "nonce"

    func obfuscationStepExpr(
        for obfuscationStep: ObfuscationStep,
        indentWidthMultiplier: Int
    ) throws -> TryExprSyntax {
        let tryIndentWidth = try exprIndentWidth(with: indentWidthMultiplier)
        let functionCallExprIndentWidth = tryIndentWidth + C.Code.Format.indentWidth
        return TryExprSyntax(
            tryKeyword: .keyword(.try, leadingTrivia: .spaces(tryIndentWidth)),
            expression: FunctionCallExprSyntax(
                calledExpression: deobfuscateFunctionAccessExpr(
                    for: obfuscationStep.technique,
                    indentWidth: functionCallExprIndentWidth
                ),
                leftParen: .leftParenToken(),
                arguments: .init {
                    LabeledExprSyntax(
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier(C.Code.Generation.deobfuscateDataFuncDataParamName)
                        ),
                        trailingComma: .commaToken()
                    )
                    LabeledExprSyntax(
                        label: .identifier(Self.nonceArgumentName),
                        colon: .colonToken(),
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier(C.Code.Generation.deobfuscateDataFuncNonceParamName)
                        )
                    )
                },
                rightParen: .rightParenToken()
            )
        )
    }

    func obfuscationStepExpr(
        for obfuscationStep: ObfuscationStep,
        withInnerExpr innerExpr: some ExprSyntaxProtocol,
        indentWidthMultiplier: Int
    ) throws -> TryExprSyntax {
        let tryIndentWidth = try exprIndentWidth(with: indentWidthMultiplier)
        let functionCallExprIndentWidth = tryIndentWidth + C.Code.Format.indentWidth
        let functionCallExprArgumentIndentWidth = functionCallExprIndentWidth + C.Code.Format.indentWidth
        return TryExprSyntax(
            tryKeyword: .keyword(.try, leadingTrivia: .spaces(tryIndentWidth)),
            expression: FunctionCallExprSyntax(
                calledExpression: deobfuscateFunctionAccessExpr(
                    for: obfuscationStep.technique,
                    indentWidth: functionCallExprIndentWidth
                ),
                leftParen: .leftParenToken(trailingTrivia: .newlines(1)),
                arguments: .init {
                    LabeledExprSyntax(
                        expression: innerExpr,
                        trailingComma: .commaToken()
                    )
                    LabeledExprSyntax(
                        label: .identifier(Self.nonceArgumentName)
                            .with(
                                \.leadingTrivia,
                                .newlines(1).appending(Trivia.spaces(functionCallExprArgumentIndentWidth))
                            ),
                        colon: .colonToken(),
                        expression: DeclReferenceExprSyntax(
                            baseName: .identifier(C.Code.Generation.deobfuscateDataFuncNonceParamName)
                        )
                    )
                },
                rightParen: .rightParenToken(
                    leadingNewlines: 1,
                    followedByLeadingSpaces: functionCallExprIndentWidth
                )
            )
        )
    }

    func deobfuscateFunctionAccessExpr(
        for technique: ObfuscationStep.Technique,
        indentWidth: Int
    ) -> some ExprSyntaxProtocol {
        let initCallExpr: FunctionCallExprSyntax
        switch technique {
        case let .compression(algorithm):
            initCallExpr = FunctionCallExprSyntax.makeDataCompressorInitializerCallExpr(algorithm: algorithm)
        case let .encryption(algorithm):
            initCallExpr = FunctionCallExprSyntax.makeDataCrypterInitializerCallExpr(algorithm: algorithm)
        case .randomization:
            initCallExpr = FunctionCallExprSyntax.makeDataShufflerInitializerCallExpr()
        }

        return MemberAccessExprSyntax.makeDeobfuscateFunctionAccessExpr(
            initCallExpr,
            dotIndentWidth: indentWidth
        )
    }
}

private extension DeobfuscateDataFunctionDeclParser {

    func exprIndentWidth(with indentWidthMultiplier: Int) throws -> Int {
        guard indentWidthMultiplier > .zero else {
            throw ParsingError.assertionFailed(
                description: "Indent width multiplier must be greater than zero."
            )
        }
        let multiplier = 1 + Int(functionNestingLevel) + (indentWidthMultiplier - 1) * 2

        return multiplier * C.Code.Format.indentWidth
    }
}
