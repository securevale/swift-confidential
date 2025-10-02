@testable import ConfidentialCore
import XCTest

final class SourceObfuscatorTests: XCTestCase {

    private typealias ObfuscationStep = SourceFileSpec.ObfuscationStep

    private typealias SUT = SourceObfuscator

    private var obfuscationStepSpy: ObfuscationStepSpy!
    private var obfuscationStepResolverSpy: ObfuscationStepResolverSpy!

    private var sut: SUT!

    override func setUp() {
        super.setUp()
        obfuscationStepSpy = .init()
        obfuscationStepResolverSpy = .init(implementationReturnValue: obfuscationStepSpy)
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
        let encryptStep = ObfuscationStep.encrypt(algorithm: .aes128GCM)
        let compressStep = ObfuscationStep.compress(algorithm: .lz4)
        var sourceFileSpec = SourceFileSpec.StubFactory.makeSpec(
            algorithm: [
                encryptStep,
                compressStep
            ],
            secrets: [
                .create(identifier: "Secrets"): [.StubFactory.makeInternalSecret()]
            ]
        )

        // when
        try sut.obfuscate(&sourceFileSpec)

        // then
        XCTAssertEqual(
            [encryptStep, compressStep],
            obfuscationStepResolverSpy.recordedSteps
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
                .encrypt(algorithm: .aes128GCM)
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
                .compress(algorithm: .lz4),
                .encrypt(algorithm: .aes128GCM)
            ]
        )
        let sourceFileSpecSnapshot = sourceFileSpec

        // when
        try sut.obfuscate(&sourceFileSpec)

        // then
        XCTAssertEqual(sourceFileSpecSnapshot, sourceFileSpec)
        XCTAssertTrue(obfuscationStepResolverSpy.recordedSteps.isEmpty)
    }
}
