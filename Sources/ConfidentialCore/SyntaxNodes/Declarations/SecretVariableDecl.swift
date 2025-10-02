import ConfidentialKit
import ConfidentialUtils
import SwiftSyntax

extension VariableDeclSyntax {

    private static let dataArgumentName: String = "data"
    private static let nonceArgumentName: String = "nonce"

    static func makeSecretVariableDecl(
        dataProjectionAttribute: AttributeSyntax,
        accessModifier: Keyword,
        name: String,
        dataArgumentExpression: ArrayExprSyntax,
        nonceArgumentExpression: IntegerLiteralExprSyntax
    ) -> Self {
        assert([.internal, .package, .public].contains(accessModifier))
        return .init(
            attributes: .init {
                dataProjectionAttribute
            },
            modifiers: .init {
                DeclModifierSyntax(
                    name: .keyword(accessModifier)
                        .with(
                            \.leadingTrivia, .newlines(1)
                            .appending(Trivia.spaces(C.Code.Format.indentWidth))
                        )
                        .with(\.trailingTrivia, .spaces(1))
                )
                DeclModifierSyntax(name: .keyword(.static))
            },
            .let,
            name: PatternSyntax(IdentifierPatternSyntax(identifier: .identifier(name))),
            type: TypeAnnotationSyntax(
                type: IdentifierTypeSyntax(
                    name: .identifier(
                        TypeInfo(of: Obfuscation.Secret.self).fullyQualifiedName
                    )
                )
            ),
            initializer: InitializerClauseSyntax(
                value: FunctionCallExprSyntax.makeInitializerCallExpr {
                    LabeledExprSyntax(
                        label: .identifier(Self.dataArgumentName),
                        colon: .colonToken(),
                        expression: dataArgumentExpression,
                        trailingComma: .commaToken()
                    )
                    LabeledExprSyntax(
                        label: .identifier(Self.nonceArgumentName),
                        colon: .colonToken(),
                        expression: nonceArgumentExpression
                    )
                }
            )
        )
    }
}
