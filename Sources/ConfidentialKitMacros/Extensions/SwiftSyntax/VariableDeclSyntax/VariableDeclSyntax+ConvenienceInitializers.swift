import SwiftSyntax

extension VariableDeclSyntax {

    init(
        leadingTrivia: Trivia = [],
        attributes: AttributeListSyntax = [],
        modifiers: DeclModifierListSyntax = [],
        _ bindingSpecifier: Keyword,
        name: String,
        type: TypeSyntax? = nil,
        initializer: InitializerClauseSyntax? = nil
    ) {
        self.init(
            leadingTrivia: leadingTrivia,
            attributes: attributes,
            modifiers: modifiers,
            bindingSpecifier,
            name: PatternSyntax(IdentifierPatternSyntax(identifier: .identifier(name))),
            type: type.map { TypeAnnotationSyntax(type: $0) },
            initializer: initializer
        )
    }

    init(
        leadingTrivia: Trivia = [],
        attributes: AttributeListSyntax = [],
        modifiers: DeclModifierListSyntax = [],
        _ bindingSpecifier: Keyword,
        name: String,
        type: TypeSyntax,
        accessors: AccessorBlockSyntax.Accessors,
        trailingTrivia: Trivia = []
    ) {
        self.init(
            leadingTrivia: leadingTrivia,
            attributes: attributes,
            modifiers: modifiers,
            bindingSpecifier: .keyword(bindingSpecifier),
            bindings: .init(
                [
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(
                            identifier: .identifier(name)
                        ),
                        typeAnnotation: TypeAnnotationSyntax(type: type),
                        accessorBlock: .init(accessors: accessors)
                    )
                ]
            ),
            trailingTrivia: trailingTrivia
        )
    }
}
