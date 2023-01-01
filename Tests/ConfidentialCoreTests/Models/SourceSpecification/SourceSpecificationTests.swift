@testable import ConfidentialCore
import XCTest

final class SourceSpecificationTests: XCTestCase {

    func test_givenTwoSecretsWithSameFieldValues_whenComparedForEquality_thenTwoSecretsAreEqual() {
        // given
        let secret1 = SourceSpecification.Secret.StubFactory.makeInternalSecret()
        let secret2 = SourceSpecification.Secret.StubFactory.makeInternalSecret()

        // when & then
        XCTAssertEqual(secret1, secret2)
    }

    func test_givenTwoSecretsWithDifferentAccessModifier_whenComparedForEquality_thenTwoSecretsAreNotEqual() {
        // given
        let secret1 = SourceSpecification.Secret.StubFactory.makeInternalSecret()
        let secret2 = SourceSpecification.Secret.StubFactory.makePublicSecret()

        // when & then
        XCTAssertNotEqual(secret1, secret2)
    }

    func test_givenTwoSecretsWithDifferentData_whenComparedForEquality_thenTwoSecretsAreNotEqual() {
        // given
        let secret1 = SourceSpecification.Secret.StubFactory.makeInternalSecret()
        let secret2 = SourceSpecification.Secret.StubFactory.makeInternalSecret(data: .init([0x20, 0x20]))

        // when & then
        XCTAssertNotEqual(secret1, secret2)
    }

    func test_givenTwoSecretsWithDifferentNonce_whenComparedForEquality_thenTwoSecretsAreNotEqual() {
        // given
        let secret1 = SourceSpecification.Secret.StubFactory.makeInternalSecret()
        let secret2 = SourceSpecification.Secret.StubFactory.makeInternalSecret(nonce: 123456789)

        // when & then
        XCTAssertNotEqual(secret1, secret2)
    }

    func test_givenTwoSecretsWithSameFieldValues_whenHashValue_thenReturnedHashesAreEqual() {
        // given
        let secret1 = SourceSpecification.Secret.StubFactory.makeInternalSecret()
        let secret2 = SourceSpecification.Secret.StubFactory.makeInternalSecret()

        // when & then
        XCTAssertEqual(secret1.hashValue, secret2.hashValue)
    }

    func test_givenTwoSecretsWithDifferentAccessModifier_whenHashValue_thenReturnedHashesAreNotEqual() {
        // given
        let secret1 = SourceSpecification.Secret.StubFactory.makeInternalSecret()
        let secret2 = SourceSpecification.Secret.StubFactory.makePublicSecret()

        // when & then
        XCTAssertNotEqual(secret1.hashValue, secret2.hashValue)
    }

    func test_givenTwoSecretsWithDifferentName_whenHashValue_thenReturnedHashesAreNotEqual() {
        // given
        let secret1 = SourceSpecification.Secret.StubFactory.makeInternalSecret(named: "secret1")
        let secret2 = SourceSpecification.Secret.StubFactory.makeInternalSecret(named: "secret2")

        // when & then
        XCTAssertNotEqual(secret1.hashValue, secret2.hashValue)
    }

    func test_givenNonEmptySecrets_whenNamespaces_thenReturnsExpectedKeys() {
        // given
        let createNamespaceKey = SourceSpecification.Secrets.Key.create(identifier: "Secrets")
        let extendNamespaceKey = SourceSpecification.Secrets.Key.extend(identifier: "Secret", moduleName: "Test")
        let secrets: SourceSpecification.Secrets = [
            createNamespaceKey: [][...],
            extendNamespaceKey: [][...]
        ]

        // when
        let keys = secrets.namespaces

        // then
        XCTAssertEqual(2, keys.count)
        XCTAssertTrue(keys.contains(createNamespaceKey))
        XCTAssertTrue(keys.contains(extendNamespaceKey))
    }

    func test_givenNonEmptySecrets_whenReadValueAtNamespace_thenReturnsExpectedValue() {
        // given
        let createNamespaceKey = SourceSpecification.Secrets.Key.create(identifier: "Secrets")
        let secret = SourceSpecification.Secret.StubFactory.makeInternalSecret()
        let secrets: SourceSpecification.Secrets = [
            createNamespaceKey: [secret][...],
            SourceSpecification.Secrets.Key.extend(identifier: "Secret", moduleName: "Test"): [][...]
        ]

        // when
        let value = secrets[createNamespaceKey]

        // then
        XCTAssertEqual([secret][...], value)
    }

    func test_givenMutableSecretsWithModifiedValueAtNamespace_whenReadValueAtNamespace_thenReturnsExpectedValue() {
        // given
        let createNamespaceKey = SourceSpecification.Secrets.Key.create(identifier: "Secrets")
        let secret = SourceSpecification.Secret.StubFactory.makeInternalSecret()
        var secrets: SourceSpecification.Secrets = [
            createNamespaceKey: [secret][...],
            SourceSpecification.Secrets.Key.extend(identifier: "Secret", moduleName: "Test"): [][...]
        ]
        secrets[createNamespaceKey] = [][...]

        // when
        let value = secrets[createNamespaceKey]

        // then
        XCTAssertEqual([][...], value)
    }

    func test_givenNonEmptySecrets_whenStartIndex_thenReturnsExpectedIndex() {
        // given
        let secretsDict = [
            SourceSpecification.Secrets.Key.create(identifier: "Secrets"): [
                SourceSpecification.Secret.StubFactory.makeInternalSecret()
            ][...],
            SourceSpecification.Secrets.Key.extend(identifier: "Secret", moduleName: "Test"): [][...]
        ]
        let secrets: SourceSpecification.Secrets = .init(secretsDict)

        // when
        let startIndex = secrets.startIndex

        // then
        XCTAssertEqual(secretsDict.startIndex, startIndex)
    }

    func test_givenNonEmptySecrets_whenEndIndex_thenReturnsExpectedIndex() {
        // given
        let secretsDict = [
            SourceSpecification.Secrets.Key.create(identifier: "Secrets"): [
                SourceSpecification.Secret.StubFactory.makeInternalSecret()
            ][...],
            SourceSpecification.Secrets.Key.extend(identifier: "Secret", moduleName: "Test"): [][...]
        ]
        let secrets: SourceSpecification.Secrets = .init(secretsDict)

        // when
        let endIndex = secrets.endIndex

        // then
        XCTAssertEqual(secretsDict.endIndex, endIndex)
    }

    func test_givenSecretsWithOneElement_whenIndexAfterStartIndex_thenReturnedIndexEqualsEndIndex() {
        // given
        let secrets: SourceSpecification.Secrets = [
            SourceSpecification.Secrets.Key.create(identifier: "Secrets"): [][...]
        ]
        let startIndex = secrets.startIndex

        // when
        let index = secrets.index(after: startIndex)

        // then
        XCTAssertEqual(secrets.endIndex, index)
    }

    func test_givenSecretsWithOneElement_whenReadElementAtStartIndex_thenReturnsExpectedElement() {
        // given
        let key = SourceSpecification.Secrets.Key.create(identifier: "Secrets")
        let value = [SourceSpecification.Secret.StubFactory.makeInternalSecret()][...]
        let secrets: SourceSpecification.Secrets = [
            key: value
        ]
        let startIndex = secrets.startIndex

        // when
        let element = secrets[startIndex]

        // then
        XCTAssertEqual(key, element.key)
        XCTAssertEqual(value, element.value)
    }
}
