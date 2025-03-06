@testable import ConfidentialCore
import XCTest

import ConfidentialKit
import ConfidentialUtils

final class DeobfuscateDataFunctionDeclParserTests: XCTestCase {

    private typealias CompressionAlgorithm = Obfuscation.Compression.CompressionAlgorithm
    private typealias EncryptionAlgorithm = Obfuscation.Encryption.SymmetricEncryptionAlgorithm
    private typealias Algorithm = SourceFileSpec.Algorithm

    private let compressionAlgorithmStub: CompressionAlgorithm = .lzfse
    private let encryptionAlgorithmStub: EncryptionAlgorithm = .aes128GCM
    private lazy var algorithmStub: Algorithm = [
        .init(technique: .compression(algorithm: compressionAlgorithmStub)),
        .init(technique: .randomization),
        .init(technique: .encryption(algorithm: encryptionAlgorithmStub))
    ]

    private let dataFullyQualifiedName = TypeInfo(of: Data.self)
        .fullyQualifiedName
    private let nonceFullyQualifiedName = TypeInfo(of: Obfuscation.Nonce.self)
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
            .formatted(using: .init(indentationWidth: .spaces(0)))
        let expectedFuncName = C.Code.Generation.deobfuscateDataFuncName
        let expectedFuncDataParamName = C.Code.Generation.deobfuscateDataFuncDataParamName
        let expectedFuncNonceParamName = C.Code.Generation.deobfuscateDataFuncNonceParamName
        let expectedFuncDataParamTypeName = dataFullyQualifiedName
        let expectedFuncNonceParamTypeName = nonceFullyQualifiedName
        let expectedFuncReturnTypeName = dataFullyQualifiedName
        XCTAssertEqual(
            """

                @inline(__always)
                private static func \(expectedFuncName)(_ \(expectedFuncDataParamName): \(expectedFuncDataParamTypeName), \(expectedFuncNonceParamName): \(expectedFuncNonceParamTypeName)) throws -> \(expectedFuncReturnTypeName) {
                    try \(dataCompressorFullyQualifiedName)(algorithm: .\(compressionAlgorithmStub.name))
                        .deobfuscate(
                            try \(dataShufflerFullyQualifiedName)()
                                .deobfuscate(
                                    try \(dataCrypterFullyQualifiedName)(algorithm: .\(encryptionAlgorithmStub.name))
                                        .deobfuscate(\(expectedFuncDataParamName), nonce: \(expectedFuncNonceParamName)),
                                    nonce: \(expectedFuncNonceParamName)
                                ),
                            nonce: \(expectedFuncNonceParamName)
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
