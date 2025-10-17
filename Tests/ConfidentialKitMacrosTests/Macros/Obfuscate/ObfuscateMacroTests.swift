@testable import ConfidentialKitMacros
import XCTest

import ConfidentialCore
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

final class ObfuscateMacroTests: XCTestCase {

    private typealias SUT = ObfuscateMacro

    private let dataStub: [UInt8] = [0x28, 0x2e, 0x29, 0x28, 0x2e, 0x29]
    private let nonceStub: Obfuscation.Nonce = 12408361842259298372

    private var algorithmGeneratorSpy: AlgorithmGeneratorSpy!
    private var generateNonceSpy: ParameterlessClosureSpy<UInt64>!
    private var obfuscationStepSpy: ObfuscationStepSpy!
    private var obfuscationStepResolverSpy: ObfuscationStepResolverSpy!
    private var secretValueEncoderSpy: DataEncoderSpy!

    private let sut: [String: any Macro.Type] = ["Obfuscate": SUT.self]

    override func setUp() {
        super.setUp()
        algorithmGeneratorSpy = .init(generateAlgorithmReturnValue: [])
        generateNonceSpy = .init(result: nonceStub)
        obfuscationStepSpy = .init()
        obfuscationStepResolverSpy = .init(implementationReturnValue: obfuscationStepSpy)
        secretValueEncoderSpy = .init(encodeReturnValue: Data(dataStub))
        SUT.configuration = .init(
            algorithmGenerator: algorithmGeneratorSpy,
            generateNonce: generateNonceSpy.closureWithError,
            secretObfuscator: SecretObfuscator(
                obfuscationStepResolver: obfuscationStepResolverSpy
            ),
            secretValueEncoder: secretValueEncoderSpy
        )
    }

    override func tearDown() {
        secretValueEncoderSpy = nil
        obfuscationStepResolverSpy = nil
        obfuscationStepSpy = nil
        generateNonceSpy = nil
        algorithmGeneratorSpy = nil
        super.tearDown()
    }

    func test_givenDeclarationsTrailingClosure_whenExpandMacro_thenProducesExpectedSourceCode() {
        // given
        let originalSource = makeOriginalSource(
            macroModifiers: ["internal", "static"],
            declarations: .init(
                [
                    .init(binding: "let", name: "secret1", value: #""Secret message 🔐""#),
                    .init(binding: "var", name: "secret2", value: #"["Secret", "message", "🔐"]"#)
                ],
                isTrailingClosure: true
            )
        )
        algorithmGeneratorSpy.generateAlgorithmReturnValue = [.shuffle]

        // when & then
        let expectedSource = makeExpandedSource(
            from: originalSource,
            inferredArguments: [
                (
                    plainValueGenericArgument: "Swift.String",
                    deobfuscateDataArgument: """
                    { data, nonce in
                        try ConfidentialCore.Obfuscation.Randomization.DataShuffler()
                            .deobfuscate(data, nonce: nonce)
                    }
                    """,
                    dataArgument: dataArgument(from: dataStub),
                    nonceArgument: nonceArgument(from: nonceStub)
                ),
                (
                    plainValueGenericArgument: "Swift.Array<Swift.String>",
                    deobfuscateDataArgument: """
                    { data, nonce in
                        try ConfidentialCore.Obfuscation.Randomization.DataShuffler()
                            .deobfuscate(data, nonce: nonce)
                    }
                    """,
                    dataArgument: dataArgument(from: dataStub),
                    nonceArgument: nonceArgument(from: nonceStub)
                )
            ]
        )
        assertMacroExpansion(
            originalSource.description,
            expandedSource: expectedSource.description,
            macros: sut
        )
        XCTAssertEqual(2, algorithmGeneratorSpy.generateAlgorithmCallCount)
        XCTAssertEqual(2, generateNonceSpy.callCount)
        XCTAssertEqual(
            [Data](repeating: Data(dataStub), count: 2),
            obfuscationStepSpy.recordedData
        )
        XCTAssertEqual(
            [Obfuscation.Nonce](repeating: nonceStub, count: 2),
            obfuscationStepSpy.recordedNonces
        )
    }

    func test_givenAlgorithmAndDeclarationsArguments_whenExpandMacro_thenProducesExpectedSourceCode() {
        // given
        let originalSources = [
            makeOriginalSource(
                algorithmArgument: ".random",
                declarations: .init(
                    [
                        .init(binding: "let", name: "secret1", value: #""🔐""#)
                    ],
                    isTrailingClosure: false
                )
            ),
            makeOriginalSource(
                algorithmArgument: ".custom([.shuffle])",
                declarations: .init(
                    [
                        .init(binding: "let", name: "secret2", value: "#\"🔐\"#")
                    ],
                    isTrailingClosure: false
                )
            ),
            makeOriginalSource(
                algorithmArgument: """
                    .custom([\
                    .compress(algorithm: .lzfse), \
                    .encrypt(algorithm: .aes256GCM)\
                    ])
                    """,
                declarations: .init(
                    [
                        .init(binding: "let", name: "secret3", value: #"["🔐"]"#)
                    ],
                    isTrailingClosure: false
                )
            )
        ]
        algorithmGeneratorSpy.generateAlgorithmReturnValue = [.shuffle]
        secretValueEncoderSpy.underlyingEncoder = JSONEncoder()

        // when & then
        let expectedSources = [
            makeExpandedSource(
                from: originalSources[0],
                inferredArguments: [
                    (
                        plainValueGenericArgument: "Swift.String",
                        deobfuscateDataArgument: """
                        { data, nonce in
                            try ConfidentialCore.Obfuscation.Randomization.DataShuffler()
                                .deobfuscate(data, nonce: nonce)
                        }
                        """,
                        dataArgument: dataArgument(from: [0x22, 0xf0, 0x9f, 0x94, 0x90, 0x22]),
                        nonceArgument: nonceArgument(from: nonceStub)
                    )
                ]
            ),
            makeExpandedSource(
                from: originalSources[1],
                inferredArguments: [
                    (
                        plainValueGenericArgument: "Swift.String",
                        deobfuscateDataArgument: """
                        { data, nonce in
                            try ConfidentialCore.Obfuscation.Randomization.DataShuffler()
                                .deobfuscate(data, nonce: nonce)
                        }
                        """,
                        dataArgument: dataArgument(from: [0x22, 0xf0, 0x9f, 0x94, 0x90, 0x22]),
                        nonceArgument: nonceArgument(from: nonceStub)
                    )
                ]
            ),
            makeExpandedSource(
                from: originalSources[2],
                inferredArguments: [
                    (
                        plainValueGenericArgument: "Swift.Array<Swift.String>",
                        deobfuscateDataArgument: """
                        { data, nonce in
                            try ConfidentialCore.Obfuscation.Compression.DataCompressor(algorithm: .lzfse)
                                .deobfuscate(
                                    try ConfidentialCore.Obfuscation.Encryption.DataCrypter(algorithm: .aes256GCM)
                                        .deobfuscate(data, nonce: nonce),
                                    nonce: nonce
                                )
                        }
                        """,
                        dataArgument: dataArgument(from: [0x5b, 0x22, 0xf0, 0x9f, 0x94, 0x90, 0x22, 0x5d]),
                        nonceArgument: nonceArgument(from: nonceStub)
                    )
                ]
            )
        ]
        zip(originalSources, expectedSources).forEach { originalSource, expectedSource in
            assertMacroExpansion(
                originalSource.description,
                expandedSource: expectedSource.description,
                macros: sut
            )
        }
        XCTAssertEqual(1, algorithmGeneratorSpy.generateAlgorithmCallCount)
        XCTAssertEqual(3, generateNonceSpy.callCount)
        XCTAssertEqual(
            [Data](repeating: Data([0x22, 0xf0, 0x9f, 0x94, 0x90, 0x22]), count: 2)
            +
            [Data](repeating: Data([0x5b, 0x22, 0xf0, 0x9f, 0x94, 0x90, 0x22, 0x5d]), count: 2),
            obfuscationStepSpy.recordedData
        )
        XCTAssertEqual(
            [Obfuscation.Nonce](repeating: nonceStub, count: 4),
            obfuscationStepSpy.recordedNonces
        )
    }

    func test_givenVariableDeclarationWithMultilineString_whenExpandMacro_thenProducesExpectedSourceCode() {
        // given
        let multilineString = #"""
        """
        t
        e
        s
        t
        """
        """#
        let originalSource = makeOriginalSource(
            declarations: .init(
                [
                    .init(binding: "let", name: "secret", value: multilineString)
                ],
                isTrailingClosure: true
            )
        )
        algorithmGeneratorSpy.generateAlgorithmReturnValue = [.shuffle]
        secretValueEncoderSpy.underlyingEncoder = JSONEncoder()

        // when & then
        let expectedData: [UInt8] = [
            0x22, 0x74, 0x5c, 0x6e, 0x65, 0x5c, 0x6e, 0x73, 0x5c, 0x6e, 0x74, 0x22
        ]
        let expectedSource = makeExpandedSource(
            from: originalSource,
            inferredArguments: [
                (
                    plainValueGenericArgument: "Swift.String",
                    deobfuscateDataArgument: """
                    { data, nonce in
                        try ConfidentialCore.Obfuscation.Randomization.DataShuffler()
                            .deobfuscate(data, nonce: nonce)
                    }
                    """,
                    dataArgument: dataArgument(from: expectedData),
                    nonceArgument: nonceArgument(from: nonceStub)
                )
            ]
        )
        assertMacroExpansion(
            originalSource.description,
            expandedSource: expectedSource.description,
            macros: sut
        )
        XCTAssertEqual(1, algorithmGeneratorSpy.generateAlgorithmCallCount)
        XCTAssertEqual(1, generateNonceSpy.callCount)
        XCTAssertEqual([Data(expectedData)], obfuscationStepSpy.recordedData)
        XCTAssertEqual([nonceStub], obfuscationStepSpy.recordedNonces)
    }

    func test_givenDeclarationsArgumentIsMissing_whenExpandMacro_thenEmitsExpectedDiagnostic() {
        // given
        let originalSource = "#Obfuscate"

        // when & then
        let expectedDiagnostic = DiagnosticSpec(
            id: .init(
                domain: "ObfuscateMacro",
                id: "DiagnosticErrors.macroMissingArgumentForParameter(at:node:)"
            ),
            message: "Missing argument for parameter #2 in macro expansion",
            line: 1,
            column: 1,
            severity: .error
        )
        assertMacroExpansion(
            originalSource,
            expandedSource: originalSource,
            diagnostics: [expectedDiagnostic],
            macros: sut
        )
    }

    func test_givenAlgorithmArgumentIsInvalidOrMalformed_whenExpandMacro_thenEmitsExpectedDiagnostic() {
        // given
        let originalSources = [
            """
            #Obfuscate(algorithm: .unknown) {
                let secret = "test"
            }
            """,
            """
            #Obfuscate(algorithm: .custom("test")) {
                let secret = "test"
            }
            """,
            """
            #Obfuscate(algorithm: .custom([.unknown])) {
                let secret = "test"
            }
            """,
            """
            #Obfuscate(algorithm: .custom([.compress(algorithm: .unknown)])) {
                let secret = "test"
            }
            """,
            """
            #Obfuscate(algorithm: .custom([.encrypt(algorithm: .unknown)])) {
                let secret = "test"
            }
            """
        ]

        // when & then
        let expectedDiagnostic = DiagnosticSpec(
            id: .init(
                domain: "ObfuscateMacro",
                id: "DiagnosticErrors.macroInvalidOrMalformedArgumentForParameter(at:node:)"
            ),
            message: "Invalid or malformed argument for parameter #1 in macro expansion",
            line: 1,
            column: 1,
            severity: .error
        )
        originalSources.forEach { originalSource in
            assertMacroExpansion(
                originalSource,
                expandedSource: originalSource,
                diagnostics: [expectedDiagnostic],
                macros: sut
            )
        }
    }

    func test_givenCustomAlgorithmIsEmpty_whenExpandMacro_thenEmitsExpectedDiagnostic() {
        // given
        let originalSource = """
        #Obfuscate(algorithm: .custom([])) {
            let secret = "test"
        }
        """

        // when & then
        let expectedDiagnostic = DiagnosticSpec(
            id: .init(
                domain: "ObfuscateMacro",
                id: "DiagnosticErrors.customAlgorithmMustIncludeAtLeastOneObfuscationStep(node:)"
            ),
            message: "Custom algorithm must include at least one obfuscation step",
            line: 1,
            column: 1,
            severity: .error
        )
        assertMacroExpansion(
            originalSource,
            expandedSource: originalSource,
            diagnostics: [expectedDiagnostic],
            macros: sut
        )
    }

    func test_givenDeclarationsArgumentIsMalformed_whenExpandMacro_thenEmitsExpectedDiagnostic() {
        // given
        let originalSource = """
        #Obfuscate {
            let secret = "test"
            print(secret)
        }
        """

        // when & then
        let expectedDiagnostic = DiagnosticSpec(
            id: .init(
                domain: "ObfuscateMacro",
                id: "DiagnosticErrors.macroExpectsVariableDeclarationsOfSupportedTypes(node:highlight:)"
            ),
            message: "'#Obfuscate' expects variable declarations of type 'String' or 'Array<String>'",
            line: 1,
            column: 12,
            severity: .error,
            highlights: ["print(secret)"]
        )
        assertMacroExpansion(
            originalSource,
            expandedSource: originalSource,
            diagnostics: [expectedDiagnostic],
            macros: sut
        )
    }

    func test_givenWildcardVariableDeclaration_whenExpandMacro_thenEmitsExpectedDiagnostic() {
        // given
        let originalSource = """
        #Obfuscate {
            let _ = "test"
        }
        """

        // when & then
        let expectedDiagnostic = DiagnosticSpec(
            id: .init(
                domain: "ObfuscateMacro",
                id: "DiagnosticErrors.variableDeclarationMustHaveValidIdentifier(node:)"
            ),
            message: "Variable declaration must have a valid identifier",
            line: 2,
            column: 5,
            severity: .error
        )
        assertMacroExpansion(
            originalSource,
            expandedSource: originalSource,
            diagnostics: [expectedDiagnostic],
            macros: sut
        )
    }

    func test_givenVariableDeclarationWithoutValue_whenExpandMacro_thenEmitsExpectedDiagnostic() {
        // given
        let variableName = "secret"
        let originalSource = """
        #Obfuscate {
            let \(variableName): String
        }
        """

        // when & then
        let expectedDiagnostic = DiagnosticSpec(
            id: .init(
                domain: "ObfuscateMacro",
                id: "DiagnosticErrors.variableMustBeAssignedLiteralOfSupportedType(variableName:node:)"
            ),
            message: "'\(variableName)' must be assigned a literal of type 'String' or 'Array<String>'",
            line: 2,
            column: 5,
            severity: .error
        )
        assertMacroExpansion(
            originalSource,
            expandedSource: originalSource,
            diagnostics: [expectedDiagnostic],
            macros: sut
        )
    }

    func test_givenVariableDeclarationWithValueOfUnsupportedType_whenExpandMacro_thenEmitsExpectedDiagnostic() {
        // given
        let variableName = "secret"
        let originalSource = """
        #Obfuscate {
            let \(variableName) = Data()
        }
        """

        // when & then
        let expectedDiagnostic = DiagnosticSpec(
            id: .init(
                domain: "ObfuscateMacro",
                id: "DiagnosticErrors.variableMustBeAssignedLiteralOfSupportedType(variableName:node:)"
            ),
            message: "'\(variableName)' must be assigned a literal of type 'String' or 'Array<String>'",
            line: 2,
            column: 5,
            severity: .error
        )
        assertMacroExpansion(
            originalSource,
            expandedSource: originalSource,
            diagnostics: [expectedDiagnostic],
            macros: sut
        )
    }

    func test_givenVariableDeclarationWithNonConstantValue_whenExpandMacro_thenEmitsExpectedDiagnostic() {
        // given
        let variableName = "secret"
        let originalSources = [
            """
            #Obfuscate {
                let \(variableName) = "test\\(test)"
            }
            """,
            """
            #Obfuscate {
                let \(variableName) = ["test", "\\(test)"]
            }
            """,
            """
            #Obfuscate {
                let \(variableName) = ["test", test]
            }
            """
        ]

        // when & then
        let expectedDiagnostic = DiagnosticSpec(
            id: .init(
                domain: "ObfuscateMacro",
                id: "DiagnosticErrors.variableValueMustBeCompileTimeConstantOfSupportedType(variableName:node:)"
            ),
            message: """
            '\(variableName)' value must be a compile-time constant of type 'String' or 'Array<String>'
            """,
            line: 2,
            column: 5,
            severity: .error
        )
        originalSources.forEach { originalSource in
            assertMacroExpansion(
                originalSource,
                expandedSource: originalSource,
                diagnostics: [expectedDiagnostic],
                macros: sut
            )
        }
    }
}

private extension ObfuscateMacroTests {

    struct OriginalSource: CustomStringConvertible {

        struct Declaration: CustomStringConvertible {

            let binding: String
            let name: String
            let value: String

            var description: String { "\(binding) \(name) = \(value)" }
        }

        struct Declarations: CustomStringConvertible {

            let value: [Declaration]
            let isTrailingClosure: Bool

            init(_ value: [Declaration], isTrailingClosure: Bool) {
                self.value = value
                self.isTrailingClosure = isTrailingClosure
            }

            var description: String {
                """
                {
                \(value.map(\.description).joined(separator: "\n"))
                }
                """
            }
        }

        let macroModifiers: [String]
        let algorithmArgument: String?
        let declarations: Declarations

        var description: String {
            let macroModifiers = macroModifiers.joined(separator: " ")
            let arguments = [
                algorithmArgument.map { "algorithm: \($0)" },
                !declarations.isTrailingClosure ? "declarations: \(declarations)" : nil
            ]
                .compactMap { $0 }
                .joined(separator: ", ")
            let trailingClosure = declarations.isTrailingClosure ? "\(declarations)" : nil
            return """
            \(macroModifiers) #Obfuscate\(!arguments.isEmpty ? "(\(arguments))" : "")\
            \(trailingClosure ?? "")
            """
        }
    }

    func makeOriginalSource(
        macroModifiers: [String] = ["static"],
        algorithmArgument: String? = .none,
        declarations: OriginalSource.Declarations
    ) -> OriginalSource {
        .init(
            macroModifiers: macroModifiers,
            algorithmArgument: algorithmArgument,
            declarations: declarations
        )
    }
}

private extension ObfuscateMacroTests {

    struct ExpandedSource: CustomStringConvertible {

        struct SecretDeclaration: CustomStringConvertible {

            let plainValueGenericArgument: String
            let deobfuscateDataArgument: String
            let variableModifiers: [String]
            let variableName: String
            let dataArgument: String
            let nonceArgument: String

            var description: String {
                let variableModifiers = variableModifiers.joined(separator: " ")
                return """
                @ConfidentialKit.Obfuscated<\(plainValueGenericArgument)>(\(deobfuscateDataArgument)) \
                \(variableModifiers) let \(variableName): ConfidentialCore.Obfuscation.Secret = \
                .init(data: \(dataArgument), nonce: \(nonceArgument))
                """
            }
        }

        let secretDeclarations: [SecretDeclaration]

        var description: String {
            secretDeclarations.map(\.description).joined(separator: "\n")
        }
    }

    func makeExpandedSource(
        from originalSource: OriginalSource,
        inferredArguments: [
            (
                plainValueGenericArgument: String,
                deobfuscateDataArgument: String,
                dataArgument: String,
                nonceArgument: String
            )
        ]
    ) -> ExpandedSource {
        .init(
            secretDeclarations: zip(originalSource.declarations.value, inferredArguments)
                .map { declaration, arguments in
                    .init(
                        plainValueGenericArgument: arguments.plainValueGenericArgument,
                        deobfuscateDataArgument: arguments.deobfuscateDataArgument,
                        variableModifiers: originalSource.macroModifiers,
                        variableName: declaration.name,
                        dataArgument: arguments.dataArgument,
                        nonceArgument: arguments.nonceArgument
                    )
                }
        )
    }
}

private extension ObfuscateMacroTests {

    func dataArgument(from data: [UInt8]) -> String {
        """
        [\(
            data
                .hexEncodedStringComponents(options: .numericLiteral)
                .joined(separator: ", ")
        )]
        """
    }

    func nonceArgument(from nonce: Obfuscation.Nonce) -> String {
        "\(nonce)"
    }
}
