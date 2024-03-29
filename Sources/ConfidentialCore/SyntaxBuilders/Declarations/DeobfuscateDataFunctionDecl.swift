import ConfidentialKit
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

struct DeobfuscateDataFunctionDecl: DeclBuildable {

    private let declNestingLevel: UInt8
    private let body: ExpressibleAsSyntaxBuildable

    init(declNestingLevel: UInt8 = .zero, body: ExpressibleAsSyntaxBuildable) {
        self.declNestingLevel = declNestingLevel
        self.body = body
    }

    func createSyntaxBuildable() -> SyntaxBuildable {
        self
    }

    func buildDecl(format: Format, leadingTrivia: Trivia?) -> DeclSyntax {
        makeUnderlyingDecl().buildDecl(format: format, leadingTrivia: leadingTrivia)
    }
}

private extension DeobfuscateDataFunctionDecl {

    func makeUnderlyingDecl() -> DeclBuildable {
        let dataTypeInfo = TypeInfo(of: Data.self)
        let nonceTypeInfo = TypeInfo(of: Obfuscation.Nonce.self)
        let indentation = Int(declNestingLevel) * C.Code.Format.indentWidth
        return FunctionDecl(
            identifier: .identifier(C.Code.Generation.deobfuscateDataFuncName),
            signature: FunctionSignature(
                input: ParameterClause {
                    FunctionParameter(
                        attributes: .none,
                        firstName: .wildcard,
                        secondName: .identifier(C.Code.Generation.deobfuscateDataFuncDataParamName),
                        colon: .colon,
                        type: SimpleTypeIdentifier(dataTypeInfo.fullyQualifiedName),
                        trailingComma: .comma
                    )
                    FunctionParameter(
                        attributes: .none,
                        firstName: .identifier(C.Code.Generation.deobfuscateDataFuncNonceParamName),
                        colon: .colon,
                        type: SimpleTypeIdentifier(nonceTypeInfo.fullyQualifiedName)
                    )
                },
                throwsOrRethrowsKeyword: .throws.withLeadingTrivia(.spaces(1)),
                output: ReturnClause(
                    returnType: SimpleTypeIdentifier(dataTypeInfo.fullyQualifiedName)
                )
            ),
            body: CodeBlock(
                leftBrace: .leftBrace.withLeadingTrivia(.spaces(1)),
                rightBrace: .rightBrace.withLeadingTrivia(.spaces(indentation))
            ) {
                CodeBlockItem(item: body)
            },
            attributesBuilder: {
                InlineAlwaysAttribute(
                    leadingTrivia: .newlines(1).appending(.spaces(indentation))
                )
            },
            modifiersBuilder: {
                DeclModifier(name: .private(leadingNewlines: 1, followedByLeadingSpaces: indentation))
                DeclModifier(name: .static)
            }
        )
    }
}
