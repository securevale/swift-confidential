@testable import ConfidentialParsing
import XCTest

import SwiftSyntax

final class NamespaceDeclParserTests: XCTestCase {

    private typealias MembersParserSpy = ParserSpy<
        ArraySlice<SourceFileSpec.Secret>,
        [MemberBlockItemSyntax]
    >

    private typealias SUT = NamespaceDeclParser<MembersParserSpy>

    private let memberNameStub = "tested"
    private let memberTypeNameStub = "Bool"

    private var membersParserSpy: MembersParserSpy!

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        membersParserSpy = .init(result: membersStub)
        membersParserSpy.consumeInput = { $0 = [] }
        sut = .init(
            membersParser: membersParserSpy
        )
    }

    override func tearDown() {
        sut = nil
        membersParserSpy = nil
        super.tearDown()
    }

    func test_givenSourceFileSpec_whenParse_thenReturnsExpectedNamespaceDeclarationsAndInputIsConsumed() throws {
        // given
        let customModuleNameStub = "Crypto"
        let namespaceNameStubs = ["A", "B", "C", "D", "E"].map { "Secrets" + $0 }
        let internalSecretStub = SourceFileSpec.Secret.StubFactory.makeInternalSecret()
        let packageSecretStub = SourceFileSpec.Secret.StubFactory.makePackageSecret()
        let publicSecretStub = SourceFileSpec.Secret.StubFactory.makePublicSecret()
        var sourceFileSpec = SourceFileSpec.StubFactory.makeSpec(
            secrets: [
                .create(identifier: namespaceNameStubs[0]): [publicSecretStub, packageSecretStub, internalSecretStub],
                .create(identifier: namespaceNameStubs[1]): [internalSecretStub, packageSecretStub],
                .create(identifier: namespaceNameStubs[2]): [internalSecretStub],
                .extend(identifier: namespaceNameStubs[3], moduleName: .none): [internalSecretStub, publicSecretStub],
                .extend(identifier: namespaceNameStubs[4], moduleName: customModuleNameStub): [publicSecretStub]
            ]
        )

        // when
        let namespaceDeclarations: [CodeBlockItemSyntax] = try sut.parse(&sourceFileSpec)

        // then
        let namespaceDeclarationsSyntaxText = namespaceDeclarations
            .map { $0.formatted(using: .init(indentationWidth: .spaces(0))) }
            .map { String(describing: $0) }
            .sorted { $0 > $1 }
        let expectedEnumDeclarationText: (String, String) -> String = { [self] accessModifier, identifier in
            """


            \(accessModifier) enum \(identifier) {

                static var \(memberNameStub): \(memberTypeNameStub) = false
            }
            """
        }
        let expectedExtensionDeclarationText: (String) -> String = { [self] identifier in
            """


            extension \(identifier) {

                static var \(memberNameStub): \(memberTypeNameStub) = false
            }
            """
        }

        XCTAssertEqual(
            [
                expectedEnumDeclarationText("public", namespaceNameStubs[0]),
                expectedEnumDeclarationText("package", namespaceNameStubs[1]),
                expectedEnumDeclarationText("internal", namespaceNameStubs[2]),
                expectedExtensionDeclarationText(namespaceNameStubs[3]),
                expectedExtensionDeclarationText("\(customModuleNameStub).\(namespaceNameStubs[4])")
            ],
            namespaceDeclarationsSyntaxText
        )
        XCTAssertEqual(5, membersParserSpy.parseRecordedInput.count)
        XCTAssertTrue(
            membersParserSpy.parseRecordedInput.contains([publicSecretStub, packageSecretStub, internalSecretStub])
        )
        XCTAssertTrue(membersParserSpy.parseRecordedInput.contains([internalSecretStub, packageSecretStub]))
        XCTAssertTrue(membersParserSpy.parseRecordedInput.contains([internalSecretStub]))
        XCTAssertTrue(membersParserSpy.parseRecordedInput.contains([internalSecretStub, publicSecretStub]))
        XCTAssertTrue(membersParserSpy.parseRecordedInput.contains([publicSecretStub]))
        XCTAssertFalse(sourceFileSpec.experimentalMode)
        XCTAssertFalse(sourceFileSpec.internalImport)
        XCTAssertTrue(sourceFileSpec.secrets.isEmpty)
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
}
