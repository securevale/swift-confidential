import SwiftSyntax
import SwiftSyntaxMacros

enum ObfuscatedMacro: PeerMacro {

    enum DeobfuscateDataArgument {
        case closure(ClosureExprSyntax)
        case functionReference(name: TokenSyntax, argumentLabels: (TokenSyntax, TokenSyntax))
    }

    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
            throw DiagnosticErrors.macroCanOnlyBeAttachedToVariableDeclaration(node: node)
        }

        let deobfuscateDataArgument = try deobfuscateDataArgument(from: node)

        let projectionVariableDecl = VariableDeclSyntax.makeSecretProjectionVariableDecl(
            modifiers: projectionVariableModifiers(for: variableDecl),
            secretIdentifier: try secretIdentifier(of: variableDecl),
            type: try projectionVariableType(from: node),
            deobfuscateDataArgument: deobfuscateDataArgument
        )

        return [
            DeclSyntax(projectionVariableDecl)
        ]
    }
}

private extension ObfuscatedMacro {

    static func secretIdentifier(of variable: VariableDeclSyntax) throws -> TokenSyntax {
        guard
            let binding = variable.bindings.first,
            let pattern = binding.pattern.as(IdentifierPatternSyntax.self)
        else {
            throw DiagnosticErrors.secretVariableDeclarationMustHaveValidIdentifier(node: variable)
        }

        return pattern.identifier.trimmed
    }
}

private extension ObfuscatedMacro {

    static func projectionVariableModifiers(for variable: VariableDeclSyntax) -> DeclModifierListSyntax {
        .init(
            variable.modifiers
                .filter { modifier in
                    C.ExpandedCode.ProjectionVariable.allowedModifiers
                        .contains(modifier.name.tokenKind)
                }
                .map(\.trimmed)
        )
    }

    static func projectionVariableType(from node: AttributeSyntax) throws -> TypeSyntax {
        let attributeName = node.attributeName
        let genericArguments: GenericArgumentListSyntax? =
        if let typeSyntax = attributeName.as(MemberTypeSyntax.self) {
            typeSyntax.genericArgumentClause?.arguments
        } else if let typeSyntax = attributeName.as(IdentifierTypeSyntax.self) {
            typeSyntax.genericArgumentClause?.arguments
        } else {
            nil
        }
        guard let type = genericArguments?.first?.argument else {
            throw DiagnosticErrors.macroMissingGenericParameter(
                named: C.genericParameterName,
                node: node
            )
        }
        #if canImport(SwiftSyntax601)
        guard case let .type(type) = type else {
            throw DiagnosticErrors.macroExpectsTypeGenericParameter(
                named: C.genericParameterName,
                node: node,
                highlight: type
            )
        }
        #endif

        return type.trimmed
    }
}

private extension ObfuscatedMacro {

    static func deobfuscateDataArgument(from node: AttributeSyntax) throws -> DeobfuscateDataArgument {
        guard
            case let .argumentList(argumentList) = node.arguments,
            let argument = argumentList.first
        else {
            throw DiagnosticErrors.macroMissingArgumentForParameter(at: 1, node: node)
        }
        if let closureExpr = argument.expression.as(ClosureExprSyntax.self) {
            return .closure(closureExpr)
        } else if let functionReferenceExpr = argument.expression.as(DeclReferenceExprSyntax.self) {
            let name = deobfuscateDataFunctionName(
                from: functionReferenceExpr
            )
            let argumentLabels = deobfuscateDataFunctionArgumentLabels(
                from: functionReferenceExpr
            )
            return .functionReference(name: name, argumentLabels: argumentLabels)
        } else {
            throw DiagnosticErrors.macroExpectsClosureOrFunctionReferenceExpression(
                node: node,
                highlight: argument.expression
            )
        }
    }

    static func deobfuscateDataFunctionName(
        from functionReferenceExpr: DeclReferenceExprSyntax
    ) -> TokenSyntax {
        functionReferenceExpr.baseName.trimmed
    }

    static func deobfuscateDataFunctionArgumentLabels(
        from functionReferenceExpr: DeclReferenceExprSyntax
    ) -> (TokenSyntax, TokenSyntax) {
        guard let arguments = functionReferenceExpr.argumentNames?.arguments else {
            return (
                C.ExpandedCode.DeobfuscateDataFunction.defaultDataArgumentLabel,
                C.ExpandedCode.DeobfuscateDataFunction.defaultNonceArgumentLabel
            )
        }

        let dataArgumentIndex = arguments.startIndex
        let dataArgumentLabel = arguments[dataArgumentIndex].name.trimmed

        let nonceArgumentIndex = arguments.index(after: dataArgumentIndex)
        let nonceArgumentLabel = arguments[nonceArgumentIndex].name.trimmed

        return (dataArgumentLabel, nonceArgumentLabel)
    }
}
