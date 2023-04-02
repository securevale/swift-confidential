import ConfidentialKit
import SwiftSyntax
import SwiftSyntaxBuilder

struct DataCrypterInitializerCallExpr: ExprBuildable {

    typealias Algorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm

    private let encryptionAlgorithm: Algorithm

    init(encryptionAlgorithm: Algorithm) {
        self.encryptionAlgorithm = encryptionAlgorithm
    }

    func createSyntaxBuildable() -> SyntaxBuildable {
        self
    }

    func buildExpr(format: Format, leadingTrivia: Trivia?) -> ExprSyntax {
        makeUnderlyingExpr().buildExpr(format: format, leadingTrivia: leadingTrivia)
    }
}

private extension DataCrypterInitializerCallExpr {

    static let algorithmArgumentName: String = "algorithm"

    func makeUnderlyingExpr() -> ExprBuildable {
        FunctionCallExpr(
            IdentifierExpr(
                TypeInfo(of: Obfuscation.Encryption.DataCrypter.self).fullyQualifiedName
            ),
            leftParen: .leftParen,
            rightParen: .rightParen,
            argumentListBuilder: {
                TupleExprElement(
                    label: .identifier(Self.algorithmArgumentName),
                    colon: .colon,
                    expression: MemberAccessExpr(
                        dot: .prefixPeriod,
                        name: .identifier(encryptionAlgorithm.name)
                    )
                )
            }
        )
    }
}
