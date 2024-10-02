import ConfidentialKit
import SwiftSyntax

extension VariableDeclSyntax {

    private static let dataArgumentName: String = "data"
    private static let nonceArgumentName: String = "nonce"

    static func makeSecretVariableDecl(
        accessModifier: TokenSyntax,
        name: String,
        dataArgumentExpression: ArrayExprSyntax,
        nonceArgumentExpression: IntegerLiteralExprSyntax,
        dataAccessWrapper: AttributeSyntax
    ) -> Self {
        assert(["internal", "public"].contains(accessModifier.text))
        return .init(
            attributes: .init {
                dataAccessWrapper
            },
            modifiers: .init {
                DeclModifierSyntax(
                    name: accessModifier
                        .with(
                            \.leadingTrivia, .newlines(1)
                            .appending(Trivia.spaces(C.Code.Format.indentWidth))
                        )
                        .with(\.trailingTrivia, .spaces(1))
                )
                DeclModifierSyntax(name: .keyword(.static))
            },
            bindingSpecifier: .keyword(.var),
            bindings: .init(
                [
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: .identifier(name)),
                        typeAnnotation: TypeAnnotationSyntax(
                            type: TypeSyntax(
                                stringLiteral: TypeInfo(of: Obfuscation.Secret.self).fullyQualifiedName
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
                ]
            )
        )
    }
}
