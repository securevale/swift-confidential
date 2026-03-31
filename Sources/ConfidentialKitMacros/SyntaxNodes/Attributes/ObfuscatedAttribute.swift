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
                    genericArgumentClause: genericArgumentClause(argument: plainValueType)
                )
            )
        ) {
            LabeledExprSyntax(
                expression: deobfuscateDataExpression
            )
        }
    }
}

private extension AttributeSyntax {

    static func genericArgumentClause(argument: TypeSyntax) -> GenericArgumentClauseSyntax {
        .init {
            #if canImport(SwiftSyntax601)
            GenericArgumentSyntax(argument: .type(argument))
            #else
            GenericArgumentSyntax(argument: argument)
            #endif
        }
    }
}
