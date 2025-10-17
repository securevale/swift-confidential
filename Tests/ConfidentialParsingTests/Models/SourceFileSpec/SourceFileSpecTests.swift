@testable import ConfidentialParsing
import XCTest

final class SourceFileSpecTests: XCTestCase {

    private typealias SUT = SourceFileSpec

    func test_givenTwoSecretsWithSameFieldValues_whenComparedForEquality_thenTwoSecretsAreEqual() {
        // given
        let secret1 = SUT.Secret.StubFactory.makeInternalSecret()
        let secret2 = SUT.Secret.StubFactory.makeInternalSecret()

        // when & then
        XCTAssertEqual(secret1, secret2)
    }

    func test_givenTwoSecretsWithDifferentAccessModifier_whenComparedForEquality_thenTwoSecretsAreNotEqual() {
        // given
        let secret1 = SUT.Secret.StubFactory.makeInternalSecret()
        let secret2 = SUT.Secret.StubFactory.makePublicSecret()

        // when & then
        XCTAssertNotEqual(secret1, secret2)
    }

    func test_givenTwoSecretsWithDifferentAlgorithm_whenComparedForEquality_thenTwoSecretsAreNotEqual() {
        // given
        let secret1 = SUT.Secret.StubFactory.makeInternalSecret(algorithm: .random)
        let secret2 = SUT.Secret.StubFactory.makeInternalSecret(algorithm: .custom([]))

        // when & then
        XCTAssertNotEqual(secret1, secret2)
    }

    func test_givenTwoSecretsWithDifferentName_whenComparedForEquality_thenTwoSecretsAreNotEqual() {
        // given
        let secret1 = SUT.Secret.StubFactory.makeInternalSecret(named: "secret1")
        let secret2 = SUT.Secret.StubFactory.makeInternalSecret(named: "secret2")

        // when & then
        XCTAssertNotEqual(secret1, secret2)
    }

    func test_givenTwoSecretsWithDifferentValue_whenComparedForEquality_thenTwoSecretsAreNotEqual() {
        // given
        let secret1 = SUT.Secret.StubFactory.makeInternalSecret(value: .string(""))
        let secret2 = SUT.Secret.StubFactory.makeInternalSecret(value: .stringArray([]))

        // when & then
        XCTAssertNotEqual(secret1, secret2)
    }

    func test_givenTwoSecretsWithSameFieldValues_whenHashValue_thenReturnedHashesAreEqual() {
        // given
        let secret1 = SUT.Secret.StubFactory.makeInternalSecret()
        let secret2 = SUT.Secret.StubFactory.makeInternalSecret()

        // when & then
        XCTAssertEqual(secret1.hashValue, secret2.hashValue)
    }

    func test_givenTwoSecretsWithDifferentAccessModifier_whenHashValue_thenReturnedHashesAreNotEqual() {
        // given
        let secret1 = SUT.Secret.StubFactory.makeInternalSecret()
        let secret2 = SUT.Secret.StubFactory.makePublicSecret()

        // when & then
        XCTAssertNotEqual(secret1.hashValue, secret2.hashValue)
    }

    func test_givenTwoSecretsWithDifferentAlgorithm_whenHashValue_thenReturnedHashesAreNotEqual() {
        // given
        let secret1 = SUT.Secret.StubFactory.makeInternalSecret(algorithm: .random)
        let secret2 = SUT.Secret.StubFactory.makeInternalSecret(algorithm: .custom([]))

        // when & then
        XCTAssertNotEqual(secret1.hashValue, secret2.hashValue)
    }

    func test_givenTwoSecretsWithDifferentName_whenHashValue_thenReturnedHashesAreNotEqual() {
        // given
        let secret1 = SUT.Secret.StubFactory.makeInternalSecret(named: "secret1")
        let secret2 = SUT.Secret.StubFactory.makeInternalSecret(named: "secret2")

        // when & then
        XCTAssertNotEqual(secret1.hashValue, secret2.hashValue)
    }

    func test_givenTwoSecretsWithDifferentValue_whenHashValue_thenReturnedHashesAreNotEqual() {
        // given
        let secret1 = SUT.Secret.StubFactory.makeInternalSecret(value: .string(""))
        let secret2 = SUT.Secret.StubFactory.makeInternalSecret(value: .stringArray([]))

        // when & then
        XCTAssertNotEqual(secret1.hashValue, secret2.hashValue)
    }

    func test_givenNonEmptySecrets_whenNamespaces_thenReturnsExpectedKeys() {
        // given
        let createNamespaceKey = SUT.Secrets.Key.create(identifier: "Secrets")
        let extendNamespaceKey = SUT.Secrets.Key.extend(identifier: "Secret", moduleName: "Test")
        let secrets: SUT.Secrets = [
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
        let createNamespaceKey = SUT.Secrets.Key.create(identifier: "Secrets")
        let secret = SUT.Secret.StubFactory.makeInternalSecret()
        let secrets: SUT.Secrets = [
            createNamespaceKey: [secret][...],
            SourceFileSpec.Secrets.Key.extend(identifier: "Secret", moduleName: "Test"): [][...]
        ]

        // when
        let value = secrets[createNamespaceKey]

        // then
        XCTAssertEqual([secret][...], value)
    }

    func test_givenMutableSecretsWithModifiedValueAtNamespace_whenReadValueAtNamespace_thenReturnsExpectedValue() {
        // given
        let createNamespaceKey = SUT.Secrets.Key.create(identifier: "Secrets")
        let secret = SUT.Secret.StubFactory.makeInternalSecret()
        var secrets: SUT.Secrets = [
            createNamespaceKey: [secret][...],
            SourceFileSpec.Secrets.Key.extend(identifier: "Secret", moduleName: "Test"): [][...]
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
            SUT.Secrets.Key.create(identifier: "Secrets"): [
                SourceFileSpec.Secret.StubFactory.makeInternalSecret()
            ][...],
            SUT.Secrets.Key.extend(identifier: "Secret", moduleName: "Test"): [][...]
        ]
        let secrets: SUT.Secrets = .init(secretsDict)

        // when
        let startIndex = secrets.startIndex

        // then
        XCTAssertEqual(secretsDict.startIndex, startIndex)
    }

    func test_givenNonEmptySecrets_whenEndIndex_thenReturnsExpectedIndex() {
        // given
        let secretsDict = [
            SUT.Secrets.Key.create(identifier: "Secrets"): [
                SUT.Secret.StubFactory.makeInternalSecret()
            ][...],
            SUT.Secrets.Key.extend(identifier: "Secret", moduleName: "Test"): [][...]
        ]
        let secrets: SUT.Secrets = .init(secretsDict)

        // when
        let endIndex = secrets.endIndex

        // then
        XCTAssertEqual(secretsDict.endIndex, endIndex)
    }

    func test_givenSecretsWithOneElement_whenIndexAfterStartIndex_thenReturnedIndexEqualsEndIndex() {
        // given
        let secrets: SUT.Secrets = [
            SUT.Secrets.Key.create(identifier: "Secrets"): [][...]
        ]
        let startIndex = secrets.startIndex

        // when
        let index = secrets.index(after: startIndex)

        // then
        XCTAssertEqual(secrets.endIndex, index)
    }

    func test_givenSecretsWithOneElement_whenReadElementAtStartIndex_thenReturnsExpectedElement() {
        // given
        let key = SUT.Secrets.Key.create(identifier: "Secrets")
        let value = [SUT.Secret.StubFactory.makeInternalSecret()][...]
        let secrets: SUT.Secrets = [
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
