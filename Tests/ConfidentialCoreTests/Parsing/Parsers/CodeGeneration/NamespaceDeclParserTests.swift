@testable import ConfidentialCore
import XCTest

import SwiftSyntax

final class NamespaceDeclParserTests: XCTestCase {

    private typealias MembersParserSpy = ParserSpy<
        ArraySlice<SourceSpecification.Secret>,
        [MemberBlockItemSyntax]
    >
    private typealias DeobfuscateDataFunctionDeclParserSpy = ParserSpy<
        SourceSpecification.Algorithm,
        any DeclSyntaxProtocol
    >

    private let memberNameStub = "tested"
    private let memberTypeNameStub = "Bool"
    private let deobfuscateDataFunctionNameStub = "test"

    private var membersParserSpy: MembersParserSpy!
    private var deobfuscateDataFunctionDeclParserSpy: DeobfuscateDataFunctionDeclParserSpy!

    private var sut: NamespaceDeclParser<MembersParserSpy, DeobfuscateDataFunctionDeclParserSpy>!

    override func setUp() {
        super.setUp()
        membersParserSpy = .init(result: membersStub)
        membersParserSpy.consumeInput = { $0 = [] }
        deobfuscateDataFunctionDeclParserSpy = .init(result: deobfuscateDataFunctionDeclStub)
        deobfuscateDataFunctionDeclParserSpy.consumeInput = { $0 = [] }
        sut = .init(
            membersParser: membersParserSpy,
            deobfuscateDataFunctionDeclParser: deobfuscateDataFunctionDeclParserSpy
        )
    }

    override func tearDown() {
        sut = nil
        deobfuscateDataFunctionDeclParserSpy = nil
        membersParserSpy = nil
        super.tearDown()
    }

    func test_givenSourceSpecification_whenParse_thenReturnsExpectedNamespaceDeclarationsAndInputIsConsumed() throws {
        // given
        let customModuleNameStub = "Crypto"
        let namespaceNameStubs = ["A", "B", "C", "D"].map { "Secrets" + $0 }
        let internalSecretStub = SourceSpecification.Secret.StubFactory.makeInternalSecret()
        let publicSecretStub = SourceSpecification.Secret.StubFactory.makePublicSecret()
        var sourceSpecification = SourceSpecification.StubFactory.makeSpecification(
            secrets: [
                .create(identifier: namespaceNameStubs[0]): [publicSecretStub, internalSecretStub],
                .create(identifier: namespaceNameStubs[1]): [internalSecretStub],
                .extend(identifier: namespaceNameStubs[2], moduleName: .none): [internalSecretStub, publicSecretStub],
                .extend(identifier: namespaceNameStubs[3], moduleName: customModuleNameStub): [publicSecretStub]
            ]
        )

        // when
        let namespaceDeclarations: [CodeBlockItemSyntax] = try sut.parse(&sourceSpecification)

        // then
        let namespaceDeclarationsSyntax = namespaceDeclarations
            .map { $0.formatted(using: .init(indentationWidth: .spaces(0))) }
            .map { String(describing: $0) }
            .sorted { $0 > $1 }

        XCTAssertEqual(
            [
                """

                
                public enum \(namespaceNameStubs[0]) {

                    static var \(memberNameStub): \(memberTypeNameStub) = false

                    static func \(deobfuscateDataFunctionNameStub)() {
                    }
                }
                """,
                """

                
                internal enum \(namespaceNameStubs[1]) {

                    static var \(memberNameStub): \(memberTypeNameStub) = false

                    static func \(deobfuscateDataFunctionNameStub)() {
                    }
                }
                """,
                """

                
                extension \(namespaceNameStubs[2]) {

                    static var \(memberNameStub): \(memberTypeNameStub) = false

                    static func \(deobfuscateDataFunctionNameStub)() {
                    }
                }
                """,
                """

                
                extension \(customModuleNameStub).\(namespaceNameStubs[3]) {

                    static var \(memberNameStub): \(memberTypeNameStub) = false

                    static func \(deobfuscateDataFunctionNameStub)() {
                    }
                }
                """
            ],
            namespaceDeclarationsSyntax
        )
        XCTAssertEqual(4, membersParserSpy.parseRecordedInput.count)
        XCTAssertTrue(membersParserSpy.parseRecordedInput.contains([publicSecretStub, internalSecretStub]))
        XCTAssertTrue(membersParserSpy.parseRecordedInput.contains([internalSecretStub]))
        XCTAssertTrue(membersParserSpy.parseRecordedInput.contains([internalSecretStub, publicSecretStub]))
        XCTAssertTrue(membersParserSpy.parseRecordedInput.contains([publicSecretStub]))
        XCTAssertEqual([[]], deobfuscateDataFunctionDeclParserSpy.parseRecordedInput)
        XCTAssertTrue(sourceSpecification.algorithm.isEmpty)
        XCTAssertFalse(sourceSpecification.internalImport)
        XCTAssertTrue(sourceSpecification.secrets.isEmpty)
    }
}

private extension NamespaceDeclParserTests {

    var membersStub: [MemberBlockItemSyntax] {
        [
            .init(
                leadingTrivia: .newline,
                decl: VariableDeclSyntax(
                    modifiers: DeclModifierListSyntax([
                        DeclModifierSyntax(
                            name: .keyword(.static, leadingTrivia: .newlines(1).appending(Trivia.spaces(4)))
                        )
                    ]),
                    bindingSpecifier: .keyword(.var),
                    bindings: PatternBindingListSyntax([
                        PatternBindingSyntax(
                            pattern: IdentifierPatternSyntax(identifier: .identifier(memberNameStub)),
                            typeAnnotation: TypeAnnotationSyntax(type: TypeSyntax(stringLiteral: memberTypeNameStub)),
                            initializer: InitializerClauseSyntax(
                                value: BooleanLiteralExprSyntax(literal: .keyword(.false))
                            )
                        )
                    ])
                )
            )
        ]
    }

    var deobfuscateDataFunctionDeclStub: any DeclSyntaxProtocol {
        FunctionDeclSyntax(
            modifiers: DeclModifierListSyntax([
                DeclModifierSyntax(
                    name: .keyword(.static, leadingTrivia: .newlines(1).appending(Trivia.spaces(4)))
                )
            ]),
            name: .identifier(deobfuscateDataFunctionNameStub),
            signature: FunctionSignatureSyntax(parameterClause: .init(parameters: [])),
            body: CodeBlockSyntax(
                leftBrace: .leftBraceToken(leadingTrivia: .spaces(1)),
                statements: [],
                rightBrace: .rightBraceToken(leadingTrivia: .spaces(4))
            )
        )
    }
}
