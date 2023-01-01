@testable import ConfidentialCore
import XCTest

final class SourceObfuscatorTests: XCTestCase {

    private typealias Technique = SourceSpecification.ObfuscationStep.Technique

    private var obfuscationStepSpy: ObfuscationStepSpy!
    private var obfuscationStepResolverSpy: ObfuscationStepResolverSpy!

    private var sut: SourceObfuscator!

    override func setUp() {
        super.setUp()
        obfuscationStepSpy = .init()
        obfuscationStepResolverSpy = .init(obfuscationStepReturnValue: obfuscationStepSpy)
        sut = .init(obfuscationStepResolver: obfuscationStepResolverSpy)
    }

    override func tearDown() {
        sut = nil
        obfuscationStepResolverSpy = nil
        obfuscationStepSpy = nil
        super.tearDown()
    }

    func test_givenSourceSpecification_whenObfuscate_thenObfuscationStepResolverCallsMatchAlgorithm() throws {
        // given
        let encryptionTechnique = Technique.encryption(algorithm: .aes128GCM)
        let compressionTechnique = Technique.compression(algorithm: .lz4)
        var sourceSpecification = SourceSpecification.StubFactory.makeSpecification(
            algorithm: [
                .init(technique: encryptionTechnique),
                .init(technique: compressionTechnique)
            ],
            secrets: [
                .create(identifier: "Secrets"): [.StubFactory.makeInternalSecret()]
            ]
        )

        // when
        try sut.obfuscate(&sourceSpecification)

        // then
        XCTAssertEqual(
            [encryptionTechnique, compressionTechnique],
            obfuscationStepResolverSpy.recordedTechniques
        )
    }

    func test_givenSourceSpecification_whenObfuscate_thenSourceSpecificationSecretDataEqualsExpectedValue() throws {
        // given
        let plainData: Data = .init([0x20, 0x20])
        let obfuscatedData: Data = .init([0xaa, 0x33, 0xa0, 0x43, 0x00, 0x8d, 0x2e, 0x1a])
        obfuscationStepSpy.obfuscateReturnValue = obfuscatedData

        let createNamespaceKey = SourceSpecification.Secrets.Key.create(identifier: "Secrets")
        var sourceSpecification = SourceSpecification.StubFactory.makeSpecification(
            algorithm: [
                .init(technique: .encryption(algorithm: .aes128GCM))
            ],
            secrets: [
                createNamespaceKey: [.StubFactory.makeInternalSecret(data: plainData)]
            ]
        )

        // when
        try sut.obfuscate(&sourceSpecification)

        // then
        XCTAssertEqual(1, sourceSpecification.secrets.count)
        XCTAssertEqual(1, sourceSpecification.secrets[createNamespaceKey]?.count)
        XCTAssertEqual([plainData], obfuscationStepSpy.recordedData)
        XCTAssertEqual(obfuscatedData, sourceSpecification.secrets[createNamespaceKey]?[0].data)
    }

    func test_givenSourceSpecificationWithEmptySecrets_whenObfuscate_thenSourceSpecificationLeftIntactAndObfuscationStepResolverNotCalled() throws {
        // given
        var sourceSpecification = SourceSpecification.StubFactory.makeSpecification(
            algorithm: [
                .init(technique: .encryption(algorithm: .aes128GCM)),
                .init(technique: .compression(algorithm: .lz4))
            ]
        )
        let sourceSpecificationSnapshot = sourceSpecification

        // when
        try sut.obfuscate(&sourceSpecification)

        // then
        XCTAssertEqual(sourceSpecificationSnapshot, sourceSpecification)
        XCTAssertTrue(obfuscationStepResolverSpy.recordedTechniques.isEmpty)
    }
}
