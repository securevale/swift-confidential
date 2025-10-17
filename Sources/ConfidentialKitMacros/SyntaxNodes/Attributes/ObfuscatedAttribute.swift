import SwiftSyntax

extension AttributeSyntax {

    static func makeObfuscatedAttribute(
        plainValueType: TypeSyntax,
        deobfuscateDataExpression: ClosureExprSyntax
    ) -> Self {
        .init(
            TypeSyntax(
                IdentifierTypeSyntax(
                    name: .identifier(C.Code.Generation.obfuscatedMacroFullyQualifiedName),
                    genericArgumentClause: .init {
                        GenericArgumentSyntax(argument: .type(plainValueType))
                    }
                )
            )
        ) {
            LabeledExprSyntax(
                expression: deobfuscateDataExpression
            )
        }
    }
}
