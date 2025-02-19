@testable import ConfidentialKitMacros
import XCTest

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

final class ObfuscatedMacroTests: XCTestCase {

    private let sut: [String: any Macro.Type] = ["Obfuscated": ObfuscatedMacro.self]

    func test_givenPlainValueGenericArgument_whenExpandMacro_thenProducesExpectedSourceCode() {
        // given
        let originalSources = [
            makeOriginalSource(plainValueGenericArgument: "Test"),
            makeOriginalSource(plainValueGenericArgument: "Swift.String"),
            makeOriginalSource(plainValueGenericArgument: "Swift.Array<Swift.String>")
        ]

        // when & then
        let expectedSources = originalSources.map { makeExpandedSource(from: $0) }
        zip(originalSources, expectedSources).forEach { originalSource, expectedSource in
            assertMacroExpansion(
                originalSource.description,
                expandedSource: expectedSource.description,
                macros: sut
            )
        }
    }

    func test_givenPlainValueGenericArgumentIsMissing_whenExpandMacro_thenEmitsExpectedDiagnostic() {
        // given
        let originalSource = """
        @Obfuscated(deobfuscateData)
        static let secret: ConfidentialKit.Obfuscation.Secret = .init(data: [], nonce: 12408361842259298372)
        """

        // when & then
        let expectedDiagnostic = DiagnosticSpec(
            id: .init(
                domain: "ObfuscatedMacro",
                id: "DiagnosticErrors.macroMissingGenericParameter(named:node:)"
            ),
            message: "Generic parameter 'PlainValue' could not be inferred",
            line: 1,
            column: 1,
            severity: .error
        )
        assertMacroExpansion(
            originalSource,
            expandedSource: """
            static let secret: ConfidentialKit.Obfuscation.Secret = .init(data: [], nonce: 12408361842259298372)
            """,
            diagnostics: [expectedDiagnostic],
            macros: sut
        )
    }

    func test_givenDeobfuscateDataFunctionWithoutArgumentLabels_whenExpandMacro_thenProducesExpectedSourceCode() {
        // given
        let originalSource = makeOriginalSource(deobfuscateDataArgument: "deobfuscateData")

        // when & then
        let expectedSource = makeExpandedSource(
            from: originalSource,
            deobfuscateDataFunctionName: "deobfuscateData",
            deobfuscateDataFunctionArgumentLabels: (.none, "nonce")
        )
        assertMacroExpansion(
            originalSource.description,
            expandedSource: expectedSource.description,
            macros: sut
        )
    }

    func test_givenDeobfuscateDataFunctionWithArgumentLabels_whenExpandMacro_thenProducesExpectedSourceCode() {
        // given
        let originalSources = [
            makeOriginalSource(deobfuscateDataArgument: "deobfuscateData(arg1:arg2:)"),
            makeOriginalSource(deobfuscateDataArgument: "deobfuscateData(_:_:)")
        ]

        // when & then
        let expectedSources = [
            makeExpandedSource(
                from: originalSources[0],
                deobfuscateDataFunctionName: "deobfuscateData",
                deobfuscateDataFunctionArgumentLabels: ("arg1", "arg2")
            ),
            makeExpandedSource(
                from: originalSources[1],
                deobfuscateDataFunctionName: "deobfuscateData",
                deobfuscateDataFunctionArgumentLabels: (.none, .none)
            )
        ]
        zip(originalSources, expectedSources).forEach { originalSource, expectedSource in
            assertMacroExpansion(
                originalSource.description,
                expandedSource: expectedSource.description,
                macros: sut
            )
        }
    }

    func test_givenDeobfuscateDataArgumentIsMissing_whenExpandMacro_thenEmitsExpectedDiagnostic() {
        // given
        let originalSource = """
        @Obfuscated<Test>
        static let secret: ConfidentialKit.Obfuscation.Secret = .init(data: [], nonce: 12408361842259298372)
        """

        // when & then
        let expectedDiagnostic = DiagnosticSpec(
            id: .init(
                domain: "ObfuscatedMacro",
                id: "DiagnosticErrors.macroMissingArgumentForParameter(at:node:)"
            ),
            message: "Missing argument for parameter #1 in macro expansion",
            line: 1,
            column: 1,
            severity: .error
        )
        assertMacroExpansion(
            originalSource,
            expandedSource: """
            static let secret: ConfidentialKit.Obfuscation.Secret = .init(data: [], nonce: 12408361842259298372)
            """,
            diagnostics: [expectedDiagnostic],
            macros: sut
        )
    }

    func test_givenDeobfuscateDataClosureExpression_whenExpandMacro_thenEmitsExpectedDiagnostic() {
        // given
        let originalSource = """
        @Obfuscated<Test>({ data, _ in data })
        static let secret: ConfidentialKit.Obfuscation.Secret = .init(data: [], nonce: 12408361842259298372)
        """

        // when & then
        let expectedDiagnostic = DiagnosticSpec(
            id: .init(
                domain: "ObfuscatedMacro",
                id: "DiagnosticErrors.macroDoesNotSupportClosureExpressions(node:highlight:)"
            ),
            message: "'@Obfuscated' does not support closure expressions, use function reference instead",
            line: 1,
            column: 1,
            severity: .error,
            highlights: ["{ data, _ in data }"]
        )
        assertMacroExpansion(
            originalSource,
            expandedSource: """
            static let secret: ConfidentialKit.Obfuscation.Secret = .init(data: [], nonce: 12408361842259298372)
            """,
            diagnostics: [expectedDiagnostic],
            macros: sut
        )
    }

    func test_givenAllowedVariableModifiers_whenExpandMacro_thenProducesExpectedSourceCode() {
        // given
        let originalSources = [
            makeOriginalSource(variableModifiers: ["private", "static"]),
            makeOriginalSource(variableModifiers: ["internal", "static"]),
            makeOriginalSource(variableModifiers: ["package", "static"]),
            makeOriginalSource(variableModifiers: ["public", "static"])
        ]

        // when & then
        let expectedSources = originalSources.map { makeExpandedSource(from: $0) }
        zip(originalSources, expectedSources).forEach { originalSource, expectedSource in
            assertMacroExpansion(
                originalSource.description,
                expandedSource: expectedSource.description,
                macros: sut
            )
        }
    }

    func test_givenDisallowedVariableModifiers_whenExpandMacro_thenProducesExpectedSourceCode() {
        // given
        let originalSources = [
            makeOriginalSource(variableModifiers: ["private", "lazy"]),
            makeOriginalSource(variableModifiers: ["internal", "nonisolated"])
        ]

        // when & then
        let expectedSources = [
            makeExpandedSource(
                from: originalSources[0],
                projectionVariableModifiers: ["private"]
            ),
            makeExpandedSource(
                from: originalSources[1],
                projectionVariableModifiers: ["internal"]
            )
        ]
        zip(originalSources, expectedSources).forEach { originalSource, expectedSource in
            assertMacroExpansion(
                originalSource.description,
                expandedSource: expectedSource.description,
                macros: sut
            )
        }
    }

    func test_givenMacroAttachedToFunctionDeclaration_whenExpandMacro_thenEmitsExpectedDiagnostic() {
        // given
        let originalSource = """
        @Obfuscated<Test>(deobfuscateData)
        static func test() {}
        """

        // when & then
        let expectedDiagnostic = DiagnosticSpec(
            id: .init(
                domain: "ObfuscatedMacro",
                id: "DiagnosticErrors.macroCanOnlyBeAttachedToVariableDeclaration(node:)"
            ),
            message: "'@Obfuscated' can only be attached to a variable declaration",
            line: 1,
            column: 1,
            severity: .error
        )
        assertMacroExpansion(
            originalSource,
            expandedSource: """
            static func test() {}
            """,
            diagnostics: [expectedDiagnostic],
            macros: sut
        )
    }

    func test_givenVariableIdentifierIsMissing_whenExpandMacro_thenEmitsExpectedDiagnostic() {
        // given
        let originalSource = """
        @Obfuscated<Test>(deobfuscateData)
        static let _: ConfidentialKit.Obfuscation.Secret = .init(data: [], nonce: 12408361842259298372)
        """

        // when & then
        let expectedDiagnostic = DiagnosticSpec(
            id: .init(
                domain: "ObfuscatedMacro",
                id: "DiagnosticErrors.secretVariableDeclarationMustHaveValidIdentifier(node:)"
            ),
            message: "Secret variable declaration must have a valid identifier",
            line: 1,
            column: 1,
            severity: .error
        )
        assertMacroExpansion(
            originalSource,
            expandedSource: """
            static let _: ConfidentialKit.Obfuscation.Secret = .init(data: [], nonce: 12408361842259298372)
            """,
            diagnostics: [expectedDiagnostic],
            macros: sut
        )
    }
}

private extension ObfuscatedMacroTests {

    struct OriginalSource: CustomStringConvertible {

        let plainValueGenericArgument: String
        let deobfuscateDataArgument: String
        let variableModifiers: [String]
        let variableName: String

        var description: String {
            let variableModifiers = variableModifiers.joined(separator: " ")
            return """
            @Obfuscated<\(plainValueGenericArgument)>(\(deobfuscateDataArgument))
            \(variableModifiers) let \(variableName): ConfidentialKit.Obfuscation.Secret = \
            .init(data: [], nonce: 12408361842259298372)
            """
        }
    }

    func makeOriginalSource(
        plainValueGenericArgument: String = "Swift.String",
        deobfuscateDataArgument: String = "deobfuscateData",
        variableModifiers: [String] = ["static"],
        variableName: String = "secret"
    ) -> OriginalSource {
        .init(
            plainValueGenericArgument: plainValueGenericArgument,
            deobfuscateDataArgument: deobfuscateDataArgument,
            variableModifiers: variableModifiers,
            variableName: variableName
        )
    }
}

private extension ObfuscatedMacroTests {

    struct ExpandedSource: CustomStringConvertible {

        let variableModifiers: [String]
        let variableName: String
        let projectionVariableModifiers: [String]
        let projectionVariableType: String
        let deobfuscateDataFunctionName: String
        let deobfuscateDataFunctionArgumentLabels: (String?, String?)

        var description: String {
            let variableModifiers = variableModifiers.joined(separator: " ")
            let projectionVariableModifiers = projectionVariableModifiers.joined(separator: " ")
            let dataArgumentLabel = deobfuscateDataFunctionArgumentLabels.0.map { "\($0): " } ?? ""
            let nonceArgumentLabel = deobfuscateDataFunctionArgumentLabels.1.map { "\($0): " } ?? ""
            return """
            \(variableModifiers) let \(variableName): ConfidentialKit.Obfuscation.Secret = \
            .init(data: [], nonce: 12408361842259298372)

            \(projectionVariableModifiers) var $\(variableName): \(projectionVariableType) {
                let data = Data(\(variableName).data)
                let nonce = \(variableName).nonce
                let value: \(projectionVariableType)
                do {
                    let deobfuscatedData = \
            try \(deobfuscateDataFunctionName)(\(dataArgumentLabel)data, \(nonceArgumentLabel)nonce)
                    value = try JSONDecoder().decode(\(projectionVariableType).self, from: deobfuscatedData)
                } catch {
                    preconditionFailure("Unexpected error: \\(error)")
                }
                return value
            }
            """
        }
    }

    func makeExpandedSource(
        from originalSource: OriginalSource,
        deobfuscateDataFunctionName: String = "deobfuscateData",
        deobfuscateDataFunctionArgumentLabels: (String?, String?) = (.none, "nonce")
    ) -> ExpandedSource {
        makeExpandedSource(
            from: originalSource,
            projectionVariableModifiers: originalSource.variableModifiers,
            deobfuscateDataFunctionName: deobfuscateDataFunctionName,
            deobfuscateDataFunctionArgumentLabels: deobfuscateDataFunctionArgumentLabels
        )
    }

    func makeExpandedSource(
        from originalSource: OriginalSource,
        projectionVariableModifiers: [String],
        deobfuscateDataFunctionName: String = "deobfuscateData",
        deobfuscateDataFunctionArgumentLabels: (String?, String?) = (.none, "nonce")
    ) -> ExpandedSource {
        .init(
            variableModifiers: originalSource.variableModifiers,
            variableName: originalSource.variableName,
            projectionVariableModifiers: projectionVariableModifiers,
            projectionVariableType: originalSource.plainValueGenericArgument,
            deobfuscateDataFunctionName: deobfuscateDataFunctionName,
            deobfuscateDataFunctionArgumentLabels: deobfuscateDataFunctionArgumentLabels
        )
    }
}
