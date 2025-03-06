import ConfidentialKit
import ConfidentialUtils
import SwiftSyntax

extension FunctionCallExprSyntax {

    private static let algorithmArgumentName: String = "algorithm"

    static func makeDataCompressorInitializerCallExpr(
        algorithm: Obfuscation.Compression.CompressionAlgorithm
    ) -> Self {
        .init(
            calledExpression: DeclReferenceExprSyntax(
                baseName: .identifier(
                    TypeInfo(of: Obfuscation.Compression.DataCompressor.self).fullyQualifiedName
                )
            ),
            leftParen: .leftParenToken(),
            arguments: .init {
                LabeledExprSyntax(
                    label: .identifier(Self.algorithmArgumentName),
                    colon: .colonToken(),
                    expression: MemberAccessExprSyntax(
                        name: .identifier(algorithm.name)
                    )
                )
            },
            rightParen: .rightParenToken()
        )
    }
}
