@testable import ConfidentialCore
import XCTest

final class SourceObfuscatorTests: XCTestCase {

    private typealias Technique = SourceFileSpec.ObfuscationStep.Technique

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

    func test_givenSourceFileSpec_whenObfuscate_thenObfuscationStepResolverCallsMatchAlgorithm() throws {
        // given
        let encryptionTechnique = Technique.encryption(algorithm: .aes128GCM)
        let compressionTechnique = Technique.compression(algorithm: .lz4)
        var sourceFileSpec = SourceFileSpec.StubFactory.makeSpec(
            algorithm: [
                .init(technique: encryptionTechnique),
                .init(technique: compressionTechnique)
            ],
            secrets: [
                .create(identifier: "Secrets"): [.StubFactory.makeInternalSecret()]
            ]
        )

        // when
        try sut.obfuscate(&sourceFileSpec)

        // then
        XCTAssertEqual(
            [encryptionTechnique, compressionTechnique],
            obfuscationStepResolverSpy.recordedTechniques
        )
    }

    func test_givenSourceFileSpec_whenObfuscate_thenSourceFileSpecSecretDataEqualsExpectedValue() throws {
        // given
        let plainData: Data = .init([0x20, 0x20])
        let obfuscatedData: Data = .init([0xaa, 0x33, 0xa0, 0x43, 0x00, 0x8d, 0x2e, 0x1a])
        obfuscationStepSpy.obfuscateReturnValue = obfuscatedData

        let createNamespaceKey = SourceFileSpec.Secrets.Key.create(identifier: "Secrets")
        var sourceFileSpec = SourceFileSpec.StubFactory.makeSpec(
            algorithm: [
                .init(technique: .encryption(algorithm: .aes128GCM))
            ],
            secrets: [
                createNamespaceKey: [.StubFactory.makeInternalSecret(data: plainData)]
            ]
        )

        // when
        try sut.obfuscate(&sourceFileSpec)

        // then
        XCTAssertEqual(1, sourceFileSpec.secrets.count)
        XCTAssertEqual(1, sourceFileSpec.secrets[createNamespaceKey]?.count)
        XCTAssertEqual([plainData], obfuscationStepSpy.recordedData)
        XCTAssertEqual(obfuscatedData, sourceFileSpec.secrets[createNamespaceKey]?[0].data)
    }

    func test_givenSourceFileSpecWithEmptySecrets_whenObfuscate_thenSourceFileSpecLeftIntactAndObfuscationStepResolverNotCalled() throws {
        // given
        var sourceFileSpec = SourceFileSpec.StubFactory.makeSpec(
            algorithm: [
                .init(technique: .encryption(algorithm: .aes128GCM)),
                .init(technique: .compression(algorithm: .lz4))
            ]
        )
        let sourceFileSpecSnapshot = sourceFileSpec

        // when
        try sut.obfuscate(&sourceFileSpec)

        // then
        XCTAssertEqual(sourceFileSpecSnapshot, sourceFileSpec)
        XCTAssertTrue(obfuscationStepResolverSpy.recordedTechniques.isEmpty)
    }
}
