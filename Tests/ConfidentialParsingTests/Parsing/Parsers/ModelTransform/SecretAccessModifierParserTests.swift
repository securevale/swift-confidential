@testable import ConfidentialParsing
import XCTest

final class SecretAccessModifierParserTests: XCTestCase {

    private typealias AccessModifier = SourceFileSpec.Secret.AccessModifier

    private typealias SUT = SecretAccessModifierParser

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        sut = .init()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_givenValidInput_whenParse_thenReturnsExpectedEnumValueAndInputIsEmpty() throws {
        // given
        var inputData = [
            ""[...],
            "internal"[...],
            "public"[...]
        ]

        // when
        let accessModifiers = try inputData.indices.map {
            try sut.parse(&inputData[$0])
        }
        
        // then
        let expectedAccessModifiers: [AccessModifier] = [
            .internal,
            .internal,
            .public
        ]
        XCTAssertEqual(inputData.count, accessModifiers.count)
        XCTAssertEqual(expectedAccessModifiers.count, accessModifiers.count)
        accessModifiers.enumerated().forEach { idx, modifier in
            XCTAssertEqual(expectedAccessModifiers[idx], modifier)
            XCTAssertTrue(inputData[idx].isEmpty)
        }
    }

    func test_givenValidInputWithExtraWhitespaces_whenParse_thenReturnsExpectedEnumValueAndInputIsEmpty() throws {
        // given
        var input = "  internal"[...]

        // when
        let accessModifier = try sut.parse(&input)

        // then
        XCTAssertEqual(.internal, accessModifier)
        XCTAssertTrue(input.isEmpty)
    }

    func test_givenInvalidInput_whenParse_thenThrowsErrorAndInputLeftIntact() {
        // given
        var input = "private"[...]

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual("private", input)
    }

    func test_givenInputWithVerticalWhitespace_whenParse_thenThrowsErrorAndInputEqualsExpectedRemainder() {
        // given
        var input = """

                    public
                    """[...]

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual(
            """

            public
            """,
            input
        )
    }

    func test_givenInputWithUnexpectedTrailingData_whenParse_thenThrowsErrorAndInputEqualsTrailingData() {
        // given
        var input = "internal Test"[...]

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual(" Test", input)
    }
}
