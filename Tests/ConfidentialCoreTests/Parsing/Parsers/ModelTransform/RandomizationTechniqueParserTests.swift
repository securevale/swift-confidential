@testable import ConfidentialCore
import XCTest

final class RandomizationTechniqueParserTests: XCTestCase {

    private let nonceStub: UInt64 = 123456789

    private var generateNonceSpy: ParameterlessClosureSpy<UInt64>!

    private var sut: RandomizationTechniqueParser!

    override func setUp() {
        super.setUp()
        generateNonceSpy = .init(result: nonceStub)
        sut = .init(generateNonce: try self.generateNonceSpy.closureWithError())
    }

    override func tearDown() {
        sut = nil
        generateNonceSpy = nil
        super.tearDown()
    }

    func test_givenValidInput_whenParse_thenReturnsExpectedEnumValueAndInputIsEmpty() throws {
        // given
        var input = "\(C.Parsing.Keywords.shuffle)"[...]

        // when
        let technique = try sut.parse(&input)

        // then
        XCTAssertEqual(.randomization(nonce: nonceStub), technique)
        XCTAssertEqual(1, generateNonceSpy.callCount)
        XCTAssertTrue(input.isEmpty)
    }

    func test_givenValidInputWithExtraWhitespaces_whenParse_thenReturnsExpectedEnumValueAndInputIsEmpty() throws {
        // given
        var input = "   \(C.Parsing.Keywords.shuffle)"[...]

        // when
        let technique = try sut.parse(&input)

        // then
        XCTAssertEqual(.randomization(nonce: nonceStub), technique)
        XCTAssertEqual(1, generateNonceSpy.callCount)
        XCTAssertTrue(input.isEmpty)
    }

    func test_givenInvalidInput_whenParse_thenThrowsErrorAndInputLeftIntact() {
        // given
        var input = "\(C.Parsing.Keywords.compress)"[...]

        // when & then
        XCTAssertThrowsError(try sut.parse(&input))
        XCTAssertEqual(.zero, generateNonceSpy.callCount)
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
        XCTAssertEqual(.zero, generateNonceSpy.callCount)
        XCTAssertEqual(" Test", input)
    }

    func test_givenValidInputAndGenerateNonceError_whenParse_thenThrowsExpectedErrorAndInputIsEmpty() {
        // given
        var input = "\(C.Parsing.Keywords.shuffle)"[...]
        let error = ErrorDummy()
        generateNonceSpy.error = error

        // when & then
        XCTAssertThrowsError(try sut.parse(&input)) {
            XCTAssertEqual(error, $0 as? ErrorDummy)
        }
        XCTAssertEqual(1, generateNonceSpy.callCount)
        XCTAssertTrue(input.isEmpty)
    }
}
