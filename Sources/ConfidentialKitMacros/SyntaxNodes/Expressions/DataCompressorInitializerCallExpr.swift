import ConfidentialCore
import ConfidentialUtils
import SwiftSyntax

extension FunctionCallExprSyntax {

    private static let algorithmArgumentLabel: String = "algorithm"

    static func makeDataCompressorInitializerCallExpr(
        algorithm: Obfuscation.Compression.CompressionAlgorithm
    ) -> Self {
        .init(
            callee: DeclReferenceExprSyntax(
                baseName: .identifier(
                    TypeInfo(of: Obfuscation.Compression.DataCompressor.self).fullyQualifiedName
                )
            )
        ) {
            LabeledExprSyntax(
                label: .identifier(algorithmArgumentLabel),
                colon: .colonToken(),
                expression: MemberAccessExprSyntax(
                    name: algorithm.identifier
                )
            )
        }
    }
}
