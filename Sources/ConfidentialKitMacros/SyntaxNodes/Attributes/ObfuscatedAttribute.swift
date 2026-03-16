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
                        #if canImport(SwiftSyntax601)
                        GenericArgumentSyntax(argument: .type(plainValueType))
                        #else
                        GenericArgumentSyntax(argument: plainValueType)
                        #endif
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
