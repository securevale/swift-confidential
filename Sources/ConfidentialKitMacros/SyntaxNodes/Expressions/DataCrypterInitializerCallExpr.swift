import ConfidentialCore
import ConfidentialUtils
import SwiftSyntax

extension FunctionCallExprSyntax {

    private static let algorithmArgumentLabel: String = "algorithm"

    static func makeDataCrypterInitializerCallExpr(
        algorithm: Obfuscation.Encryption.SymmetricEncryptionAlgorithm
    ) -> Self {
        .init(
            callee: DeclReferenceExprSyntax(
                baseName: .identifier(
                    TypeInfo(of: Obfuscation.Encryption.DataCrypter.self).fullyQualifiedName
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
