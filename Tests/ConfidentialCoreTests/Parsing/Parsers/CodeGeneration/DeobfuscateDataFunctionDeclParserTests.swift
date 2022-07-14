@testable import ConfidentialCore
import XCTest

import ConfidentialKit

final class DeobfuscateDataFunctionDeclParserTests: XCTestCase {

    private typealias CompressionAlgorithm = Obfuscation.Compression.CompressionAlgorithm
    private typealias EncryptionAlgorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm
    private typealias Algorithm = SourceSpecification.Algorithm

    private let compressionAlgorithmStub: CompressionAlgorithm = .lzfse
    private let randomizationNonceStub: UInt64 = 123456789
    private let encryptionAlgorithmStub: EncryptionAlgorithm = .aes128GCM
    private lazy var algorithmStub: Algorithm = [
        .init(technique: .compression(algorithm: compressionAlgorithmStub)),
        .init(technique: .randomization(nonce: randomizationNonceStub)),
        .init(technique: .encryption(algorithm: encryptionAlgorithmStub))
    ]

    private let dataFullyQualifiedName = TypeInfo(of: Data.self)
        .fullyQualifiedName
    private let dataCompressorFullyQualifiedName = TypeInfo(of: Obfuscation.Compression.DataCompressor.self)
        .fullyQualifiedName
    private let dataShufflerFullyQualifiedName = TypeInfo(of: Obfuscation.Randomization.DataShuffler.self)
        .fullyQualifiedName
    private let dataCrypterFullyQualifiedName = TypeInfo(of: Obfuscation.Encryption.DataCrypter.self)
        .fullyQualifiedName

    func test_givenAlgorithmAndNestingLevelSetToOne_whenParse_thenReturnsExpectedFunctionDeclAndAlgorithmIsEmpty() throws {
        // given
        var algorithm = algorithmStub
        let parser = DeobfuscateDataFunctionDeclParser(functionNestingLevel: 1)

        // when
        let functionDecl = try parser.parse(&algorithm)

        // then
        let functionDeclSyntax = functionDecl
            .createMemberDeclListItem()
            .buildSyntax(format: .init(indentWidth: .zero))
        let expectedFuncName = C.Code.Generation.deobfuscateDataFuncName
        let expectedFuncParamName = C.Code.Generation.deobfuscateDataFuncParamName
        let expectedFuncParamTypeName = dataFullyQualifiedName
        let expectedFuncReturnTypeName = dataFullyQualifiedName
        XCTAssertEqual(
            """

                @inline(__always)
                private static func \(expectedFuncName)(_ \(expectedFuncParamName): \(expectedFuncParamTypeName)) throws -> \(expectedFuncReturnTypeName) {
                    try \(dataCompressorFullyQualifiedName)(algorithm: .\(compressionAlgorithmStub.name))
                        .deobfuscate(
                            try \(dataShufflerFullyQualifiedName)(nonce: \(randomizationNonceStub))
                                .deobfuscate(
                                    try \(dataCrypterFullyQualifiedName)(algorithm: .\(encryptionAlgorithmStub.name))
                                        .deobfuscate(\(expectedFuncParamName))
                                )
                        )
                }
            """,
            .init(describing: functionDeclSyntax)
        )
        XCTAssertTrue(algorithm.isEmpty)
    }

    func test_givenEmptyAlgorithm_whenParse_thenThrowsExpectedError() {
        // given
        var algorithm = Algorithm()
        let parser = DeobfuscateDataFunctionDeclParser(functionNestingLevel: .zero)

        // when & then
        XCTAssertThrowsError(try parser.parse(&algorithm)) { error in
            XCTAssertEqual(
                "Obfuscation algorithm must consist of at least one obfuscation step.",
                "\(error)"
            )
        }
    }
}
