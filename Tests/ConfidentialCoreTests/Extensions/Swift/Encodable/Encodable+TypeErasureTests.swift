@testable import ConfidentialCore
import XCTest

final class Encodable_TypeErasureTests: XCTestCase {

    func test_givenTypeErasedEncodable_whenJSONEncoded_thenNoThrowAndUnderlyingEncodableProducesExpectedResult() {
        // given
        let encodableValue = "Test"
        let encodableSpy = EncodableSpy<String>()
        encodableSpy.encodableValue = encodableValue
        let anyEncodable = encodableSpy.eraseToAnyEncodable()

        // when & then
        var result: Data = .init()
        XCTAssertNoThrow(
            result = try JSONEncoder().encode(anyEncodable)
        )
        XCTAssertEqual(1, encodableSpy.encodeCallCount)
        XCTAssertEqual(#""\#(encodableValue)""#, String(decoding: result, as: UTF8.self))
    }
}
