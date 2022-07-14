@testable import ConfidentialCore
import XCTest

import SwiftSyntaxBuilder

final class NamespaceDeclParserTests: XCTestCase {

    private typealias MembersParserSpy = ParserSpy<
        ArraySlice<SourceSpecification.Secret>,
        [ExpressibleAsMemberDeclListItem]
    >
    private typealias DeobfuscateDataFunctionDeclParserSpy = ParserSpy<
        SourceSpecification.Algorithm,
        ExpressibleAsMemberDeclListItem
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

    func test_givenSourceSpecification_whenParse_thenReturnsExpectedNamespaceDeclarationsAndSourceSpecificationIsEmpty() throws {
        // given
        let namespaceNameStub = "Secrets"
        let secretStub = SourceSpecification.Secret.StubFactory.makeSecret()
        var sourceSpecification = SourceSpecification.StubFactory.makeSpecification(
            secrets: [
                .create(identifier: namespaceNameStub): [secretStub],
                .extend(identifier: namespaceNameStub, moduleName: .none): [secretStub]
            ]
        )

        // when
        let namespaceDeclarations: [ExpressibleAsCodeBlockItem] = try sut.parse(&sourceSpecification)

        // then
        let namespaceDeclarationsSyntax = namespaceDeclarations
            .map { $0.createCodeBlockItem() }
            .map { $0.buildSyntax(format: .init(indentWidth: .zero)) }
            .map { String(describing: $0) }
            .sorted()

        XCTAssertEqual(
            [
                """

                enum \(namespaceNameStub) {

                    static var \(memberNameStub): \(memberTypeNameStub) = false

                    static func \(deobfuscateDataFunctionNameStub)() {
                    }
                }
                """,
                """

                extension \(namespaceNameStub) {

                    static var \(memberNameStub): \(memberTypeNameStub) = false

                    static func \(deobfuscateDataFunctionNameStub)() {
                    }
                }
                """
            ],
            namespaceDeclarationsSyntax
        )
        XCTAssertEqual([[secretStub], [secretStub]], membersParserSpy.parseRecordedInput)
        XCTAssertEqual([[]], deobfuscateDataFunctionDeclParserSpy.parseRecordedInput)
        XCTAssertTrue(sourceSpecification.algorithm.isEmpty)
        XCTAssertTrue(sourceSpecification.secrets.isEmpty)
    }
}

private extension NamespaceDeclParserTests {

    var membersStub: [ExpressibleAsMemberDeclListItem] {
        [
            VariableDecl(
                modifiers: ModifierList([
                    DeclModifier(name: .static.withLeadingTrivia(.newlines(1).appending(.spaces(4))))
                ]),
                letOrVarKeyword: .var,
                bindings: PatternBindingList([
                    PatternBinding(
                        pattern: IdentifierPattern(memberNameStub),
                        typeAnnotation: TypeAnnotation(memberTypeNameStub),
                        initializer: InitializerClause(
                            value: BooleanLiteralExpr(booleanLiteral: .false.withoutTrivia())
                        )
                    )
                ])
            )
        ]
    }

    var deobfuscateDataFunctionDeclStub: ExpressibleAsMemberDeclListItem {
        FunctionDecl(
            modifiers: ModifierList([
                DeclModifier(name: .static.withLeadingTrivia(.newlines(1).appending(.spaces(4))))
            ]),
            identifier: .identifier(deobfuscateDataFunctionNameStub),
            signature: FunctionSignature(input: ParameterClause()),
            body: CodeBlock(
                leftBrace: .leftBrace.withLeadingTrivia(.spaces(1)),
                statements: CodeBlockItemList([]),
                rightBrace: .rightBrace.withLeadingTrivia(.spaces(4))
            )
        )
    }
}
