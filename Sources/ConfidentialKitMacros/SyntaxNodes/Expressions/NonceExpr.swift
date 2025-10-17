import ConfidentialCore
import SwiftSyntax

extension IntegerLiteralExprSyntax {

    static func makeNonceExpr(from nonce: Obfuscation.Nonce) -> IntegerLiteralExprSyntax {
        .init(literal: .integerLiteral("\(nonce)"))
    }
}
