import ConfidentialKit
import Foundation
import SwiftSyntax

extension FunctionDeclSyntax {

    static func makeDeobfuscateDataFunctionDecl(
        nestingLevel: Int = .zero,
        body: some ExprSyntaxProtocol
    ) -> Self {
        let dataTypeInfo = TypeInfo(of: Data.self)
        let nonceTypeInfo = TypeInfo(of: Obfuscation.Nonce.self)
        let indentation = nestingLevel * C.Code.Format.indentWidth
        return .init(
            attributes: .init {
                AttributeSyntax
                    .inlineAlways
                    .with(\.leadingTrivia, .newlines(1).appending(Trivia.spaces(indentation)))
            },
            modifiers: .init {
                DeclModifierSyntax(
                    name: .keyword(
                        .private,
                        leadingTrivia: .newlines(1).appending(Trivia.spaces(indentation)),
                        trailingTrivia: .spaces(1)
                    )
                )
                DeclModifierSyntax(name: .keyword(.static))
            },
            name: .identifier(C.Code.Generation.deobfuscateDataFuncName),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: .init {
                        FunctionParameterSyntax(
                            firstName: .wildcardToken(),
                            secondName: .identifier(C.Code.Generation.deobfuscateDataFuncDataParamName),
                            type: IdentifierTypeSyntax(name: .identifier(dataTypeInfo.fullyQualifiedName)),
                            trailingComma: .commaToken()
                        )
                        FunctionParameterSyntax(
                            firstName: .identifier(C.Code.Generation.deobfuscateDataFuncNonceParamName),
                            type: IdentifierTypeSyntax(name: .identifier(nonceTypeInfo.fullyQualifiedName))
                        )
                    }
                ),
                effectSpecifiers: .init(throwsSpecifier: .keyword(.throws, leadingTrivia: .spaces(1))),
                returnClause: ReturnClauseSyntax(
                    type: IdentifierTypeSyntax(name: .identifier(dataTypeInfo.fullyQualifiedName))
                )
            ),
            body: CodeBlockSyntax(
                leftBrace: .leftBraceToken(leadingTrivia: .spaces(1)),
                rightBrace: .rightBraceToken(leadingTrivia: .spaces(indentation))
            ) {
                CodeBlockItemSyntax(item: .init(body))
            }
        )
    }
}
