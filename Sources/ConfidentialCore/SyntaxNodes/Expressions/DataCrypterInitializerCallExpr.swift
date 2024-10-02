import ConfidentialKit
import SwiftSyntax

extension FunctionCallExprSyntax {

    private static let algorithmArgumentName: String = "algorithm"

    static func makeDataCrypterInitializerCallExpr(
        algorithm: Obfuscation.Encryption.SymmetricEncryptionAlgorithm
    ) -> Self {
        .init(
            calledExpression: DeclReferenceExprSyntax(
                baseName: .identifier(
                    TypeInfo(of: Obfuscation.Encryption.DataCrypter.self).fullyQualifiedName
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
