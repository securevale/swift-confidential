@testable import ConfidentialCore
import XCTest

final class TypeInfoTests: XCTestCase {

    func test_givenNestedTypeInfo_whenFullyQualifiedName_thenReturnsExpectedValue() {
        // given
        let typeInfo = TypeInfo(of: Swift.String.Encoding.self)

        // when
        let fullyQualifiedName = typeInfo.fullyQualifiedName

        // then
        XCTAssertEqual("Swift.String.Encoding", fullyQualifiedName)
    }

    func test_givenNestedTypeInfo_whenModuleName_thenReturnsExpectedValue() {
        // given
        let typeInfo = TypeInfo(of: Swift.String.Encoding.self)

        // when
        let moduleName = typeInfo.moduleName

        // then
        XCTAssertEqual("Swift", moduleName)
    }

    func test_givenNestedTypeInfo_whenFullName_thenReturnsExpectedValue() {
        // given
        let typeInfo = TypeInfo(of: Swift.String.Encoding.self)

        // when
        let fullName = typeInfo.fullName

        // then
        XCTAssertEqual("String.Encoding", fullName)
    }

    func test_givenNestedTypeInfo_whenName_thenReturnsExpectedValue() {
        // given
        let typeInfo = TypeInfo(of: Swift.String.Encoding.self)

        // when
        let name = typeInfo.name

        // then
        XCTAssertEqual("Encoding", name)
    }

    func test_givenTopLevelTypeInfo_whenFullyQualifiedName_thenReturnsExpectedValue() {
        // given
        let typeInfo = TypeInfo(of: Foundation.Data.self)

        // when
        let fullyQualifiedName = typeInfo.fullyQualifiedName

        // then
        XCTAssertEqual("Foundation.Data", fullyQualifiedName)
    }

    func test_givenTopLevelTypeInfo_whenModuleName_thenReturnsExpectedValue() {
        // given
        let typeInfo = TypeInfo(of: Foundation.Data.self)

        // when
        let moduleName = typeInfo.moduleName

        // then
        XCTAssertEqual("Foundation", moduleName)
    }

    func test_givenTopLevelTypeInfo_whenFullName_thenReturnsExpectedValue() {
        // given
        let typeInfo = TypeInfo(of: Foundation.Data.self)

        // when
        let fullName = typeInfo.fullName

        // then
        XCTAssertEqual("Data", fullName)
    }

    func test_givenTopLevelTypeInfo_whenName_thenReturnsExpectedValue() {
        // given
        let typeInfo = TypeInfo(of: Foundation.Data.self)

        // when
        let name = typeInfo.name

        // then
        XCTAssertEqual("Data", name)
    }
}
