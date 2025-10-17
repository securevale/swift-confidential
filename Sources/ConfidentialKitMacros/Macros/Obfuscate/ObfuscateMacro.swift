import ConfidentialCore
import ConfidentialUtils
import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

enum ObfuscateMacro: DeclarationMacro {

    static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let arguments = try arguments(from: node)

        if case let .custom(algorithm) = arguments.algorithm, algorithm.isEmpty {
            throw DiagnosticErrors.customAlgorithmMustIncludeAtLeastOneObfuscationStep(
                node: node
            )
        }

        let secretDeclarations = try secretDeclarations(
            from: try plainSecrets(
                from: try variableDeclarations(from: arguments.declarations)
            ),
            using: arguments.algorithm
        )

        return secretDeclarations
    }
}

private extension ObfuscateMacro {

    static func secretDeclarations(
        from plainSecrets: [PlainSecret],
        using algorithm: Obfuscation.AlgorithmSpecifier
    ) throws -> [DeclSyntax] {
        try plainSecrets.map { plainSecret in
            var secret = Obfuscation.Secret(
                data: try Coding.encode(plainSecret.value),
                nonce: try Obfuscation.generateNonce()
            )
            let algorithm = switch algorithm {
            case let .custom(algorithm): algorithm
            case .random: Obfuscation.generateAlgorithm()
            }

            try Obfuscation.obfuscate(&secret, using: algorithm)

            return DeclSyntax(
                VariableDeclSyntax.makeSecretVariableDecl(
                    dataProjectionAttribute: .makeObfuscatedAttribute(
                        plainValueType: TypeSyntax(
                            stringLiteral: plainSecret.value.typeInfo.fullyQualifiedName
                        ),
                        deobfuscateDataExpression: .makeDeobfuscateDataClosureExpr(
                            algorithm: algorithm.reversed()
                        )
                    ),
                    name: plainSecret.name,
                    dataArgumentExpression: .makeUInt8ArrayExpr(from: secret.data),
                    nonceArgumentExpression: .makeNonceExpr(from: secret.nonce)
                )
            )
        }
    }
}

private extension ObfuscateMacro {

    struct PlainSecret: Equatable {

        enum Value: Equatable, Encodable {

            case string(String)
            case stringArray(Array<String>)

            var typeInfo: TypeInfo {
                switch self {
                case let .string(value): TypeInfo(of: type(of: value))
                case let .stringArray(value): TypeInfo(of: type(of: value))
                }
            }

            func encode(to encoder: any Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case let .string(value):
                    try container.encode(value)
                case let .stringArray(value):
                    try container.encode(value)
                }
            }
        }

        let name: String
        let value: Value
    }

    static func plainSecrets(from variables: [VariableDeclSyntax]) throws -> [PlainSecret] {
        try variables.map { variable in // swiftlint:disable:this closure_body_length
            let binding = variable.bindings[variable.bindings.startIndex]
            guard
                let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self),
                case let .identifier(name) = identifierPattern.identifier.tokenKind
            else {
                throw DiagnosticErrors.variableDeclarationMustHaveValidIdentifier(node: variable)
            }

            guard let expression = binding.initializer?.value else {
                throw DiagnosticErrors.variableMustBeAssignedLiteralOfSupportedType(
                    variableName: name,
                    node: variable
                )
            }
            switch expression.as(ExprSyntaxEnum.self) {
            case let .stringLiteralExpr(expression):
                guard let value = string(from: expression) else {
                    throw DiagnosticErrors.variableValueMustBeCompileTimeConstantOfSupportedType(
                        variableName: name,
                        node: variable
                    )
                }
                return PlainSecret(name: name, value: .string(value))
            case let .arrayExpr(expression):
                guard let value = stringArray(from: expression) else {
                    throw DiagnosticErrors.variableValueMustBeCompileTimeConstantOfSupportedType(
                        variableName: name,
                        node: variable
                    )
                }
                return PlainSecret(name: name, value: .stringArray(value))
            default:
                throw DiagnosticErrors.variableMustBeAssignedLiteralOfSupportedType(
                    variableName: name,
                    node: variable
                )
            }
        }
    }

    static func string(from expression: StringLiteralExprSyntax) -> String? {
        let segments = expression.segments
        guard segments.allSatisfy({ $0.is(StringSegmentSyntax.self) }) else {
            return nil
        }

        return segments.reduce(
            into: "",
            { string, segment in
                string.append(
                    segment
                        .cast(StringSegmentSyntax.self)
                        .content
                        .text
                )
            }
        )
    }

    static func stringArray(from expression: ArrayExprSyntax) -> [String]? {
        let elements = expression.elements
        let stringArray = elements
            .map(\.expression)
            .compactMap { $0.as(StringLiteralExprSyntax.self) }
            .compactMap(string(from:))
        guard elements.count == stringArray.count else { return nil }

        return stringArray
    }
}

private extension ObfuscateMacro {

    static func variableDeclarations(from closure: ClosureExprSyntax) throws -> [VariableDeclSyntax] {
        let statements = closure.statements
        let variables = try statements.map { statement in
            guard let variable = statement.item.as(VariableDeclSyntax.self) else {
                throw DiagnosticErrors.macroExpectsVariableDeclarationsOfSupportedTypes(
                    node: closure,
                    highlight: statement
                )
            }

            return variable
        }

        return variables
    }
}

private extension ObfuscateMacro {

    enum Coding {

        static func encode(_ value: PlainSecret.Value) throws -> Data {
            try configuration.secretValueEncoder.encode(value)
        }
    }
}

private extension Obfuscation {

    static func generateNonce() throws -> Nonce {
        try ObfuscateMacro.configuration.generateNonce()
    }

    static func generateAlgorithm() -> Algorithm {
        ObfuscateMacro.configuration.algorithmGenerator.generateAlgorithm()
    }

    static func obfuscate(_ secret: inout Secret, using algorithm: Algorithm) throws {
        try ObfuscateMacro.configuration.secretObfuscator.obfuscate(&secret, using: algorithm)
    }
}
