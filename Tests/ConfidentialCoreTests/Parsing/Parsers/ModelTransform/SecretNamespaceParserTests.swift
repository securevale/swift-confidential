@testable import ConfidentialCore
import XCTest

final class SecretNamespaceParserTests: XCTestCase {

    private typealias Namespace = SecretNamespaceParser.Namespace

    private let secretsNamespaceStub = "Secrets"
    private let secretModuleStub = "SecretModule"

    private var sut: SecretNamespaceParser!

    override func setUp() {
        super.setUp()
        sut = .init()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_givenValidInputData_whenParse_thenReturnsExpectedEnumValuesAndInputIsEmpty() throws {
        // given
        var inputData = [
            ""[...],
            "\(C.Parsing.Keywords.create) \(secretsNamespaceStub)"[...],
            "\(C.Parsing.Keywords.extend) \(secretsNamespaceStub)"[...],
            "\(C.Parsing.Keywords.extend) \(secretsNamespaceStub) \(C.Parsing.Keywords.from) \(secretModuleStub)"
        ]

        // when
        let namespaces = try inputData.indices.map {
            try sut.parse(&inputData[$0])
        }

        // then
        let expectedNamespaces: [Namespace] = [
            .extend(identifier: "ConfidentialKit.Obfuscation.Secret", moduleName: "ConfidentialKit"),
            .create(identifier: secretsNamespaceStub),
            .extend(identifier: secretsNamespaceStub, moduleName: .none),
            .extend(identifier: secretsNamespaceStub, moduleName: secretModuleStub)
        ]
        XCTAssertEqual(inputData.count, namespaces.count)
        XCTAssertEqual(expectedNamespaces.count, namespaces.count)
        namespaces.enumerated().forEach { idx, namespace in
            XCTAssertEqual(expectedNamespaces[idx], namespace)
            XCTAssertTrue(inputData[idx].isEmpty)
        }
    }

    func test_givenValidInputWithExtraWhitespaces_whenParse_thenReturnsExpectedEnumValueAndInputIsEmpty() throws {
        // given
        var input = " \(C.Parsing.Keywords.extend) \(secretsNamespaceStub)   \(C.Parsing.Keywords.from) \(secretModuleStub)"[...]

        // when
        let namespace = try sut.parse(&input)

        // then
        XCTAssertEqual(.extend(identifier: secretsNamespaceStub, moduleName: secretModuleStub), namespace)
        XCTAssertTrue(input.isEmpty)
    }

    func test_givenInvalidInput_whenParse_thenThrowsErrorAndInputLeftIntact() {
        // given
        var input = "\(C.Parsing.Keywords.shuffle)"[...]

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual("\(C.Parsing.Keywords.shuffle)", input)
    }

    func test_givenInputWithUnexpectedTrailingData_whenParse_thenThrowsErrorAndInputEqualsTrailingData() {
        // given
        var input = "\(C.Parsing.Keywords.create) \(secretsNamespaceStub) Test"[...]

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual(" Test", input)
    }
}
