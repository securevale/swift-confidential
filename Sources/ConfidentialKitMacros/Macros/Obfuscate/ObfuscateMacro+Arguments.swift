import ConfidentialCore
import SwiftSyntax

extension ObfuscateMacro {

    struct Arguments {

        fileprivate static let algorithmArgumentLabel: String = "algorithm"
        fileprivate static let algorithmArgumentPosition: Int = 1
        fileprivate static let declarationsArgumentLabel: String = "declarations"
        fileprivate static let declarationsArgumentPosition: Int = 2

        let algorithm: Obfuscation.AlgorithmSpecifier
        let declarations: ClosureExprSyntax

        init(
            algorithm: Obfuscation.AlgorithmSpecifier = .random,
            declarations: ClosureExprSyntax
        ) {
            self.algorithm = algorithm
            self.declarations = declarations
        }
    }

    static func arguments(from node: some FreestandingMacroExpansionSyntax) throws -> Arguments {
        let arguments = node.arguments
        guard
            let declarationsArgument = arguments
                .first(labeled: Arguments.declarationsArgumentLabel)
                .flatMap({ $0.expression.as(ClosureExprSyntax.self) })
                ?? node.trailingClosure
        else {
            throw DiagnosticErrors.macroMissingArgumentForParameter(
                at: Arguments.declarationsArgumentPosition,
                node: node
            )
        }
        guard
            let algorithmArgument = arguments.first(labeled: Arguments.algorithmArgumentLabel)
        else {
            return .init(declarations: declarationsArgument)
        }
        guard let algorithmSpecifier = algorithmSpecifier(from: algorithmArgument.expression) else {
            throw DiagnosticErrors.macroInvalidOrMalformedArgumentForParameter(
                at: Arguments.algorithmArgumentPosition,
                node: node
            )
        }

        return .init(
            algorithm: algorithmSpecifier,
            declarations: declarationsArgument
        )
    }
}

private extension ObfuscateMacro {

    typealias CompressionAlgorithm = Obfuscation.Compression.CompressionAlgorithm
    typealias EncryptionAlgorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm

    static func algorithmSpecifier(from expression: some ExprSyntaxProtocol) -> Obfuscation.AlgorithmSpecifier? {
        let enumCase = enumCase(from: expression)
        switch enumCase.identifier.text {
        case "custom":
            guard
                let stepsAssociatedValue = enumCase.associatedValues?.first,
                let stepsArrayExpr = stepsAssociatedValue.expression.as(ArrayExprSyntax.self)
            else {
                return nil
            }
            var steps: [Obfuscation.Step] = []
            for element in stepsArrayExpr.elements {
                guard let step = obfuscationStep(from: element.expression) else {
                    return nil
                }
                steps.append(step)
            }
            return .custom(steps)
        case "random":
            return .random
        default:
            return nil
        }
    }

    static func obfuscationStep(from expression: some ExprSyntaxProtocol) -> Obfuscation.Step? {
        let enumCase = enumCase(from: expression)
        switch enumCase.identifier.text {
        case "compress":
            guard
                let algorithmAssociatedValue = enumCase.associatedValues?.first,
                let algorithm = compressionAlgorithm(from: algorithmAssociatedValue.expression)
            else {
                return nil
            }
            return .compress(algorithm: algorithm)
        case "encrypt":
            guard
                let algorithmAssociatedValue = enumCase.associatedValues?.first,
                let algorithm = encryptionAlgorithm(from: algorithmAssociatedValue.expression)
            else {
                return nil
            }
            return .encrypt(algorithm: algorithm)
        case "shuffle":
            return .shuffle
        default:
            return nil
        }
    }

    static func compressionAlgorithm(from expression: some ExprSyntaxProtocol) -> CompressionAlgorithm? {
        let enumCase = enumCase(from: expression)
        return .allCases.first { algorithm in
            algorithm.identifier.text == enumCase.identifier.text
        }
    }

    static func encryptionAlgorithm(from expression: some ExprSyntaxProtocol) -> EncryptionAlgorithm? {
        let enumCase = enumCase(from: expression)
        return .allCases.first { algorithm in
            algorithm.identifier.text == enumCase.identifier.text
        }
    }
}

private extension ObfuscateMacro {

    struct EnumCase {
        let identifier: TokenSyntax
        let associatedValues: LabeledExprListSyntax?
    }

    static func enumCase(from expression: some ExprSyntaxProtocol) -> EnumCase {
        guard let expression = expression.as(FunctionCallExprSyntax.self) else {
            let caseAccessExpr = expression.cast(MemberAccessExprSyntax.self)
            let identifier = caseAccessExpr.declName.baseName.trimmed

            return .init(identifier: identifier, associatedValues: .none)
        }

        let caseAccessExpr = expression.calledExpression.cast(MemberAccessExprSyntax.self)
        let identifier = caseAccessExpr.declName.baseName.trimmed
        let associatedValues = expression.arguments

        return .init(identifier: identifier, associatedValues: associatedValues)
    }
}
