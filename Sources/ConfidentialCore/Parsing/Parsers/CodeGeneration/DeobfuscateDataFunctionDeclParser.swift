import Parsing
import SwiftSyntaxBuilder

struct DeobfuscateDataFunctionDeclParser: Parser {

    typealias Algorithm = SourceSpecification.Algorithm

    private let functionNestingLevel: UInt8

    init(functionNestingLevel: UInt8) {
        self.functionNestingLevel = functionNestingLevel
    }

    func parse(_ input: inout Algorithm) throws -> ExpressibleAsMemberDeclListItem {
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

        return DeobfuscateDataFunctionDecl(
            declNestingLevel: functionNestingLevel,
            body: bodyExpr
        )
    }
}

private extension DeobfuscateDataFunctionDeclParser {

    typealias ObfuscationStep = SourceSpecification.ObfuscationStep

    static let nonceArgumentName: String = "nonce"

    func obfuscationStepExpr(
        for obfuscationStep: ObfuscationStep,
        indentWidthMultiplier: Int
    ) throws -> ExpressibleAsExprBuildable {
        let tryIndentWidth = try exprIndentWidth(with: indentWidthMultiplier)
        let functionCallExprIndentWidth = tryIndentWidth + C.Code.Format.indentWidth
        return TryExpr(
            tryKeyword: .try.withLeadingTrivia(.spaces(tryIndentWidth)),
            expression: FunctionCallExpr(
                calledExpression: deobfuscateFunctionAccessExpr(
                    for: obfuscationStep.technique,
                    indentWidth: functionCallExprIndentWidth
                ),
                leftParen: .leftParen,
                rightParen: .rightParen,
                argumentListBuilder: {
                    TupleExprElement(
                        expression: IdentifierExpr(C.Code.Generation.deobfuscateDataFuncDataParamName),
                        trailingComma: .comma
                    )
                    TupleExprElement(
                        label: .identifier(Self.nonceArgumentName),
                        colon: .colon,
                        expression: IdentifierExpr(C.Code.Generation.deobfuscateDataFuncNonceParamName)
                    )
                }
            )
        )
    }

    func obfuscationStepExpr(
        for obfuscationStep: ObfuscationStep,
        withInnerExpr innerExpr: ExpressibleAsExprBuildable,
        indentWidthMultiplier: Int
    ) throws -> ExpressibleAsExprBuildable {
        let tryIndentWidth = try exprIndentWidth(with: indentWidthMultiplier)
        let functionCallExprIndentWidth = tryIndentWidth + C.Code.Format.indentWidth
        let functionCallExprArgumentIndentWidth = functionCallExprIndentWidth + C.Code.Format.indentWidth
        return TryExpr(
            tryKeyword: .try.withLeadingTrivia(.spaces(tryIndentWidth)),
            expression: FunctionCallExpr(
                calledExpression: deobfuscateFunctionAccessExpr(
                    for: obfuscationStep.technique,
                    indentWidth: functionCallExprIndentWidth
                ),
                leftParen: .leftParen.withTrailingTrivia(.newlines(1)),
                rightParen: .rightParen(
                    leadingNewlines: 1,
                    followedByLeadingSpaces: functionCallExprIndentWidth
                ),
                argumentListBuilder: {
                    TupleExprElement(
                        expression: innerExpr,
                        trailingComma: .comma.withoutTrivia()
                    )
                    TupleExprElement(
                        label: .identifier(Self.nonceArgumentName)
                            .withLeadingTrivia(
                                .newlines(1)
                                .appending(.spaces(functionCallExprArgumentIndentWidth))
                            ),
                        colon: .colon,
                        expression: IdentifierExpr(C.Code.Generation.deobfuscateDataFuncNonceParamName)
                    )
                }
            )
        )
    }

    func deobfuscateFunctionAccessExpr(
        for technique: ObfuscationStep.Technique,
        indentWidth: Int
    ) -> ExpressibleAsExprBuildable {
        let initCallExpr: ExpressibleAsExprBuildable
        switch technique {
        case let .compression(algorithm):
            initCallExpr = DataCompressorInitializerCallExpr(compressionAlgorithm: algorithm)
        case let .encryption(algorithm):
            initCallExpr = DataCrypterInitializerCallExpr(encryptionAlgorithm: algorithm)
        case .randomization:
            initCallExpr = DataShufflerInitializerCallExpr()
        }

        return DeobfuscateFunctionAccessExpr(initCallExpr, dotIndentWidth: indentWidth)
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
