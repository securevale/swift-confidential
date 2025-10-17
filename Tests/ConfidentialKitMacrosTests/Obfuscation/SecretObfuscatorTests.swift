@testable import ConfidentialKitMacros
import XCTest

import ConfidentialCore

final class SecretObfuscatorTests: XCTestCase {

    private typealias SUT = SecretObfuscator

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

    func test_givenSecretAndAlgorithm_whenObfuscate_thenObfuscationStepResolverCallsMatchAlgorithm() throws {
        // given
        var secret = Obfuscation.Secret(data: [0x20, 0x20], nonce: 123456789)
        let encryptStep = Obfuscation.Step.encrypt(algorithm: .aes128GCM)
        let compressStep = Obfuscation.Step.compress(algorithm: .lz4)
        let algorithm = [encryptStep, compressStep]

        // when
        try sut.obfuscate(&secret, using: algorithm)

        // then
        XCTAssertEqual(
            [encryptStep, compressStep],
            obfuscationStepResolverSpy.recordedSteps
        )
    }

    func test_givenSecretAndAlgorithm_whenObfuscate_thenSecretDataEqualsExpectedValue() throws {
        // given
        let plainData: [UInt8] = [0x20, 0x20]
        let obfuscatedData: [UInt8] = [0xaa, 0x33, 0xa0, 0x43, 0x00, 0x8d, 0x2e, 0x1a]
        obfuscationStepSpy.obfuscateReturnValue = Data(obfuscatedData)

        var secret = Obfuscation.Secret(data: plainData, nonce: 123456789)
        let algorithm = [Obfuscation.Step.shuffle]

        // when
        try sut.obfuscate(&secret, using: algorithm)

        // then
        XCTAssertEqual([Data(plainData)], obfuscationStepSpy.recordedData)
        XCTAssertEqual(obfuscatedData, secret.data)
    }

    func test_givenSecretWithEmptyDataAndAlgorithm_whenObfuscate_thenSecretLeftIntactAndObfuscationStepResolverNotCalled() throws {
        // given
        var secret = Obfuscation.Secret(data: [], nonce: 123456789)
        let secretSnapshot = secret
        let algorithm = [Obfuscation.Step.shuffle]

        // when
        try sut.obfuscate(&secret, using: algorithm)

        // then
        XCTAssertEqual(secretSnapshot, secret)
        XCTAssertTrue(obfuscationStepResolverSpy.recordedSteps.isEmpty)
    }

    func test_givenSecretAndEmptyAlgorithm_whenObfuscate_thenSecretLeftIntactAndObfuscationStepResolverNotCalled() throws {
        // given
        var secret = Obfuscation.Secret(data: [0x20, 0x20], nonce: 123456789)
        let secretSnapshot = secret
        let algorithm: [Obfuscation.Step] = []

        // when
        try sut.obfuscate(&secret, using: algorithm)

        // then
        XCTAssertEqual(secretSnapshot, secret)
        XCTAssertTrue(obfuscationStepResolverSpy.recordedSteps.isEmpty)
    }
}
