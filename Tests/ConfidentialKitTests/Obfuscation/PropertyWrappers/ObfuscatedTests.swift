@testable import ConfidentialKit
import XCTest

final class ObfuscatedTests: XCTestCase {

    private let secretPlainValue: SingleValue = .StubFactory.makeSecretMessage()
    private let secretNonce: Obfuscation.Nonce = .StubFactory.makeNonce()

    private var secretStub: Obfuscation.Secret!
    private var deobfuscateDataSpy: DeobfuscateDataFuncSpy!
    private var dataDecoderSpy: DataDecoderSpy!

    private var sut: Obfuscated<SingleValue>!

    override func setUp() {
        super.setUp()
        secretStub = .StubFactory.makeJSONEncodedSecret(
            with: secretPlainValue,
            nonce: secretNonce
        )
        deobfuscateDataSpy = .init()
        dataDecoderSpy = .init(underlyingDecoder: JSONDecoder())
        sut = .init(
            wrappedValue: secretStub,
            deobfuscateData: deobfuscateDataSpy.deobfuscateData,
            decoder: dataDecoderSpy
        )
    }

    override func tearDown() {
        sut = nil
        dataDecoderSpy = nil
        deobfuscateDataSpy = nil
        secretStub = nil
        super.tearDown()
    }

    func test_whenWrappedValue_thenReturnsExpectedSecretStub() {
        // when
        let wrappedValue = sut.wrappedValue

        // then
        XCTAssertEqual(secretStub, wrappedValue)
    }

    func test_whenProjectedValue_thenReturnsExpectedPlainValue() {
        // when
        let projectedValue = sut.projectedValue

        // then
        XCTAssertEqual(secretPlainValue, projectedValue)
    }

    func test_whenProjectedValue_thenDeobfuscateDataFuncCalledOnce() {
        // when
        _ = sut.projectedValue

        // then
        XCTAssertEqual([.init(secretStub.data)], deobfuscateDataSpy.recordedData)
        XCTAssertEqual([secretStub.nonce], deobfuscateDataSpy.recordedNonces)
    }

    func test_whenProjectedValue_thenDataDecoderCalledOnce() {
        // when
        _ = sut.projectedValue

        // then
        XCTAssertEqual([.init(secretStub.data)], dataDecoderSpy.decodeRecordedData)
    }
}
