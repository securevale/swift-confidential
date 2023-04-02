import ConfidentialKit
import SwiftSyntax
import SwiftSyntaxBuilder

struct SecretDecl: DeclBuildable {

    private let accessModifier: TokenSyntax
    private let name: TokenSyntax
    private let dataArgumentExpression: ExpressibleAsArrayExpr
    private let nonceArgumentExpression: ExpressibleAsIntegerLiteralExpr
    private let dataAccessWrapper: ExpressibleAsCustomAttribute

    init(
        accessModifier: TokenSyntax,
        name: String,
        dataArgumentExpression: ExpressibleAsArrayExpr,
        nonceArgumentExpression: ExpressibleAsIntegerLiteralExpr,
        dataAccessWrapper: ExpressibleAsCustomAttribute
    ) {
        self.accessModifier = accessModifier
        assert(["internal", "public"].contains(self.accessModifier.text))
        self.name = .identifier(name)
        self.dataArgumentExpression = dataArgumentExpression
        self.nonceArgumentExpression = nonceArgumentExpression
        self.dataAccessWrapper = dataAccessWrapper
    }

    func createSyntaxBuildable() -> SyntaxBuildable {
        self
    }

    func buildDecl(format: Format, leadingTrivia: Trivia?) -> DeclSyntax {
        makeUnderlyingDecl().buildDecl(format: format, leadingTrivia: leadingTrivia)
    }
}

private extension SecretDecl {

    static let dataArgumentName: String = "data"
    static let nonceArgumentName: String = "nonce"

    func makeUnderlyingDecl() -> DeclBuildable {
        VariableDecl(
            letOrVarKeyword: .var,
            attributesBuilder: {
                dataAccessWrapper.createCustomAttribute()
            },
            modifiersBuilder: {
                DeclModifier(
                    name: accessModifier
                        .withoutTrivia()
                        .withLeadingTrivia(
                            .newlines(1)
                            .appending(.spaces(C.Code.Format.indentWidth))
                        )
                        .withTrailingTrivia(.spaces(1))
                )
                DeclModifier(name: .static)
            },
            bindingsBuilder: {
                PatternBinding(
                    pattern: IdentifierPattern(identifier: name),
                    typeAnnotation: TypeAnnotation(
                        TypeInfo(of: Obfuscation.Secret.self).fullyQualifiedName
                    ),
                    initializer: InitializerClause(
                        value: InitializerCallExpr {
                            TupleExprElement(
                                label: .identifier(Self.dataArgumentName),
                                colon: .colon,
                                expression: dataArgumentExpression.createArrayExpr(),
                                trailingComma: .comma
                            )
                            TupleExprElement(
                                label: .identifier(Self.nonceArgumentName),
                                colon: .colon,
                                expression: nonceArgumentExpression.createIntegerLiteralExpr()
                            )
                        }
                    )
                )
            }
        )
    }
}

protocol ExpressibleAsSecretDecl {
    func createSecretDecl() -> SecretDecl
}

extension SecretDecl: ExpressibleAsSecretDecl {

    func createSecretDecl() -> SecretDecl { self }
}
