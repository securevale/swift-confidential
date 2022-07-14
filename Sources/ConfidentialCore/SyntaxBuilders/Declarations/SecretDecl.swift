import ConfidentialKit
import SwiftSyntax
import SwiftSyntaxBuilder

struct SecretDecl: DeclBuildable {

    private let name: TokenSyntax
    private let dataArgumentExpression: ExpressibleAsArrayExpr
    private let dataAccessWrapper: ExpressibleAsCustomAttribute

    init(
        name: String,
        dataArgumentExpression: ExpressibleAsArrayExpr,
        dataAccessWrapper: ExpressibleAsCustomAttribute
    ) {
        self.name = .identifier(name)
        self.dataArgumentExpression = dataArgumentExpression
        self.dataAccessWrapper = dataAccessWrapper
    }

    func buildDecl(format: Format, leadingTrivia: Trivia?) -> DeclSyntax {
        makeUnderlyingDecl().buildDecl(format: format, leadingTrivia: leadingTrivia)
    }
}

private extension SecretDecl {

    static let dataArgumentName: String = "data"

    func makeUnderlyingDecl() -> DeclBuildable {
        VariableDecl(
            letOrVarKeyword: .var,
            attributesBuilder: {
                dataAccessWrapper.createCustomAttribute()
            },
            modifiersBuilder: {
                DeclModifier(name: .static(leadingNewlines: 1))
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
                                expression: dataArgumentExpression.createArrayExpr()
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
