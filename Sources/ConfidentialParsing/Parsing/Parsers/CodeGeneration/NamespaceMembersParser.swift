import ConfidentialCore
import Parsing
import SwiftSyntax

struct NamespaceMembersParser<SecretDeclParser: Parser>: Parser
where
    SecretDeclParser.Input == SourceFileSpec.Secret,
    SecretDeclParser.Output == VariableDeclSyntax
{ // swiftlint:disable:this opening_brace

    typealias Secret = SourceFileSpec.Secret

    private let secretDeclParser: SecretDeclParser

    init(secretDeclParser: SecretDeclParser) {
        self.secretDeclParser = secretDeclParser
    }

    func parse(_ input: inout ArraySlice<Secret>) throws -> [MemberBlockItemSyntax] {
        let declarations = try macroExpansionGroups(from: &input)
            .sorted { lhs, rhs in
                let (lhs, rhs) = (lhs.key, rhs.key)
                guard lhs.accessModifier != rhs.accessModifier else {
                    switch (lhs.algorithm, rhs.algorithm) {
                    case (.random, .custom): return true
                    default: return false
                    }
                }

                return lhs.accessModifier.rawValue > rhs.accessModifier.rawValue
            }
            .map { descriptor, group in
                macroExpansionDecl(descriptor: descriptor, declarations: group)
            }

        return declarations.map {
            MemberBlockItemSyntax(leadingTrivia: .newline, decl: $0)
        }
    }
}

private extension NamespaceMembersParser {

    struct MacroExpansionDescriptor: Hashable {
        let accessModifier: Secret.AccessModifier
        let algorithm: Secret.Algorithm
    }

    typealias MacroExpansionGroups = Dictionary<MacroExpansionDescriptor, Array<DeclSyntax>>

    func macroExpansionGroups(from secrets: inout ArraySlice<Secret>) throws -> MacroExpansionGroups {
        var parsedSecretsCount: Int = .zero
        var groups: MacroExpansionGroups = [:]
        do {
            try secrets.forEach { secret in
                let descriptor = MacroExpansionDescriptor(
                    accessModifier: secret.accessModifier,
                    algorithm: secret.algorithm
                )
                let declaration = DeclSyntax(
                    try secretDeclParser.parse(secret)
                )
                groups[descriptor, default: []].append(declaration)

                parsedSecretsCount += 1
            }
            secrets.removeFirst(parsedSecretsCount)
        } catch {
            secrets.removeFirst(parsedSecretsCount)
            throw error
        }

        return groups
    }
}

private extension NamespaceMembersParser {

    static var algorithmArgumentLabel: String { "algorithm" }

    func macroExpansionDecl(
        descriptor: MacroExpansionDescriptor,
        declarations: Array<DeclSyntax>
    ) -> MacroExpansionDeclSyntax {
        .init(
            modifiers: .init {
                DeclModifierSyntax(
                    name: keyword(for: descriptor.accessModifier)
                        .with(\.leadingTrivia, .newline)
                        .with(\.trailingTrivia, .spaces(1))
                )
                DeclModifierSyntax(name: .keyword(.static))
            },
            macroName: .identifier(C.Code.Generation.obfuscateMacroName),
            leftParen: .leftParenToken(),
            arguments: .init {
                LabeledExprSyntax(
                    label: .identifier(Self.algorithmArgumentLabel),
                    colon: .colonToken(),
                    expression: memberAccessExpr(for: descriptor.algorithm)
                )
            },
            rightParen: .rightParenToken(),
            trailingClosure: .init(
                statements: CodeBlockItemListSyntax(
                    declarations.map {
                        CodeBlockItemSyntax(item: .decl($0))
                    }
                )
            )
        )
    }

    func memberAccessExpr(for algorithm: Secret.Algorithm) -> any ExprSyntaxProtocol {
        let identifier = algorithm.identifier
        switch algorithm {
        case let .custom(algorithm):
            return FunctionCallExprSyntax(
                callee: MemberAccessExprSyntax(name: identifier)
            ) {
                LabeledExprSyntax(
                    expression: ArrayExprSyntax(
                        algorithm,
                        transformingElementsWith: memberAccessExpr(for:)
                    )
                )
            }
        case .random:
            return MemberAccessExprSyntax(name: identifier)
        }
    }

    func memberAccessExpr(for obfuscationStep: Obfuscation.Step) -> any ExprSyntaxProtocol {
        let identifier = obfuscationStep.identifier
        switch obfuscationStep {
        case let .compress(algorithm):
            return FunctionCallExprSyntax(
                callee: MemberAccessExprSyntax(name: identifier)
            ) {
                LabeledExprSyntax(
                    label: .identifier(Self.algorithmArgumentLabel),
                    colon: .colonToken(),
                    expression: MemberAccessExprSyntax(name: algorithm.identifier)
                )
            }
        case let .encrypt(algorithm):
            return FunctionCallExprSyntax(
                callee: MemberAccessExprSyntax(name: identifier)
            ) {
                LabeledExprSyntax(
                    label: .identifier(Self.algorithmArgumentLabel),
                    colon: .colonToken(),
                    expression: MemberAccessExprSyntax(name: algorithm.identifier)
                )
            }
        case .shuffle:
            return MemberAccessExprSyntax(name: identifier)
        }
    }

    func keyword(for accessModifier: Secret.AccessModifier) -> TokenSyntax {
        switch accessModifier {
        case .internal: .keyword(.internal)
        case .package: .keyword(.package)
        case .public: .keyword(.public)
        }
    }
}
