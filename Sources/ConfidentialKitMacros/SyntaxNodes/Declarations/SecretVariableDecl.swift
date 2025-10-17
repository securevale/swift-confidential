import ConfidentialCore
import ConfidentialUtils
import SwiftSyntax

extension VariableDeclSyntax {

    private static let dataArgumentLabel: String = "data"
    private static let nonceArgumentLabel: String = "nonce"

    static func makeSecretVariableDecl(
        dataProjectionAttribute: AttributeSyntax,
        name: String,
        dataArgumentExpression: ArrayExprSyntax,
        nonceArgumentExpression: IntegerLiteralExprSyntax
    ) -> Self {
        return .init(
            attributes: .init {
                dataProjectionAttribute
            },
            .let,
            name: name,
            type: TypeSyntax(
                IdentifierTypeSyntax(
                    name: .identifier(
                        TypeInfo(of: Obfuscation.Secret.self).fullyQualifiedName
                    )
                )
            ),
            initializer: InitializerClauseSyntax(
                value: FunctionCallExprSyntax(
                    callee: MemberAccessExprSyntax(
                        declName: .init(baseName: .keyword(.`init`))
                    )
                ) {
                    LabeledExprSyntax(
                        label: .identifier(dataArgumentLabel),
                        colon: .colonToken(trailingTrivia: .space),
                        expression: dataArgumentExpression
                    )
                    LabeledExprSyntax(
                        label: .identifier(nonceArgumentLabel),
                        colon: .colonToken(trailingTrivia: .space),
                        expression: nonceArgumentExpression
                    )
                }
            )
        )
    }
}
