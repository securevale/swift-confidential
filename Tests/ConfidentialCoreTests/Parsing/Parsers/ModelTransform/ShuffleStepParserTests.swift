@testable import ConfidentialCore
import XCTest

final class ShuffleStepParserTests: XCTestCase {

    private typealias SUT = ShuffleStepParser

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
        var input = "\(C.Parsing.Keywords.shuffle)"[...]

        // when
        let step = try sut.parse(&input)

        // then
        XCTAssertEqual(.shuffle, step)
        XCTAssertTrue(input.isEmpty)
    }

    func test_givenValidInputWithExtraWhitespaces_whenParse_thenReturnsExpectedEnumValueAndInputIsEmpty() throws {
        // given
        var input = "   \(C.Parsing.Keywords.shuffle)"[...]

        // when
        let step = try sut.parse(&input)

        // then
        XCTAssertEqual(.shuffle, step)
        XCTAssertTrue(input.isEmpty)
    }

    func test_givenInvalidInput_whenParse_thenThrowsErrorAndInputLeftIntact() {
        // given
        var input = "\(C.Parsing.Keywords.compress)"[...]

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual("\(C.Parsing.Keywords.compress)", input)
    }

    func test_givenInputWithLeadingVerticalWhitespace_whenParse_thenThrowsErrorAndInputLeftIntact() {
        // given
        var input = """

                    \(C.Parsing.Keywords.shuffle)
                    """[...]

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual(
            """

            \(C.Parsing.Keywords.shuffle)
            """,
            input
        )
    }

    func test_givenInputWithUnexpectedTrailingData_whenParse_thenThrowsErrorAndInputEqualsTrailingData() {
        // given
        var input = "\(C.Parsing.Keywords.shuffle) Test"[...]

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual(" Test", input)
    }
}
