import ConfidentialKit
import SwiftSyntax
import SwiftSyntaxBuilder

struct DataCompressorInitializerCallExpr: ExprBuildable {

    typealias Algorithm = Obfuscation.Compression.CompressionAlgorithm

    private let compressionAlgorithm: Algorithm

    init(compressionAlgorithm: Algorithm) {
        self.compressionAlgorithm = compressionAlgorithm
    }

    func createSyntaxBuildable() -> SyntaxBuildable {
        self
    }

    func buildExpr(format: Format, leadingTrivia: Trivia?) -> ExprSyntax {
        makeUnderlyingExpr().buildExpr(format: format, leadingTrivia: leadingTrivia)
    }
}

private extension DataCompressorInitializerCallExpr {

    static let algorithmArgumentName: String = "algorithm"

    func makeUnderlyingExpr() -> ExprBuildable {
        FunctionCallExpr(
            IdentifierExpr(
                TypeInfo(of: Obfuscation.Compression.DataCompressor.self).fullyQualifiedName
            ),
            leftParen: .leftParen,
            rightParen: .rightParen,
            argumentListBuilder: {
                TupleExprElement(
                    label: .identifier(Self.algorithmArgumentName),
                    colon: .colon,
                    expression: MemberAccessExpr(
                        dot: .prefixPeriod,
                        name: .identifier(compressionAlgorithm.name)
                    )
                )
            }
        )
    }
}
