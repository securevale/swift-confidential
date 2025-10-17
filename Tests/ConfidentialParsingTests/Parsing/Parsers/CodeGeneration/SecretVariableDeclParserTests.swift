@testable import ConfidentialParsing
import XCTest

import SwiftSyntax

final class SecretVariableDeclParserTests: XCTestCase {

    private typealias SUT = SecretVariableDeclParser

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        sut = .init()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_givenSecret_whenParse_thenReturnsExpectedSecretDecl() throws {
        // given
        let secrets = [
            makeSecretStub(value: .string("test")),
            makeSecretStub(value: .stringArray(["t", "e", "s", "t"]))
        ]

        // when
        let secretDecls = try secrets.map { secret in
            (secret, try XCTUnwrap(sut.parse(secret)))
        }

        // then
        secretDecls.forEach { secret, secretDecl in
            let expectedValue = switch secret.value {
            case let .string(value):
                #""\#(value)""#
            case let .stringArray(value):
                "[\(value.map { #""\#($0)""# }.joined(separator: ", "))]"
            }
            XCTAssertEqual(
                """

                let \(secret.name) = \(expectedValue)
                """,
                .init(describing: syntax(from: secretDecl))
            )
        }
    }
}

private extension SecretVariableDeclParserTests {

    typealias Secret = SourceFileSpec.Secret

    func makeSecretStub(value: Secret.Value) -> Secret {
        .init(
            accessModifier: .internal,
            algorithm: .random,
            name: "secret",
            value: value
        )
    }
}

private extension SecretVariableDeclParserTests {

    func syntax(from secretDecl: VariableDeclSyntax) -> Syntax {
        secretDecl
            .formatted(using: .init(indentationWidth: .spaces(0)))
    }
}
