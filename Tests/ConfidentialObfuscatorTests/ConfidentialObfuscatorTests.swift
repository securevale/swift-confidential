@testable import ConfidentialObfuscator
import ConfidentialKit
import XCTest

final class ConfidentialObfuscatorTests: XCTestCase {

    func test_givenConfig_whenObfuscate_thenReturnsStringWithObfuscatedSecrets() throws {
        // given
        let value: String = "variable_value"
        let crypter = Obfuscation.Encryption.DataCrypter(algorithm: .aes128GCM)

        let configuration = """
            algorithm:
              - encrypt using aes-128-gcm
            defaultAccessModifier: public
            secrets:
              - name: variable_name
                value: \(value)
            """

        // when
        let obfuscatedString: String = try ConfidentialObfuscator.obfuscate(configurationData: Data(configuration.utf8))

        // then

        // 1. Check the output string
        do {
            var obfuscatedString = obfuscatedString
            // Modify Secret initialization in two steps:
            // 1. Strip random data array.
            //    Look for all `0xFF` with coma+space or closing square bracket in the end.
            //    If ends with square bracket replace it with square bracket, else just empty string.
            obfuscatedString.replace(#/0x[0-9a-fA-F]{1,2}(,\s?|\])/#) { match in if match.output.1 == "]" { "]" } else { "" } }
            // 2. Replace `, nonce: 00000` with zero.
            obfuscatedString.replace(#/,\s?nonce:\s?\d+/#, with: ", nonce: 0")

            let expectedString: String = """
            import ConfidentialKit
            import Foundation

            extension ConfidentialKit.Obfuscation.Secret {

                @ConfidentialKit.Obfuscated<Swift.String>(deobfuscateData)
                public static var variable_name: ConfidentialKit.Obfuscation.Secret = .init(data: [], nonce: 0)

                @inline(__always)
                private static func deobfuscateData(_ data: Foundation.Data, nonce: Swift.UInt64) throws -> Foundation.Data {
                    try ConfidentialKit.Obfuscation.Encryption.DataCrypter(algorithm: .aes128GCM)
                        .deobfuscate(data, nonce: nonce)
                }
            }
            """

            XCTAssertEqual(obfuscatedString, expectedString)
        }

        // 2. Check if the obfuscated value is correct
        do {
            // Get nonce value
            let nonceString = try XCTUnwrap(obfuscatedString.firstMatch(of: #/,\s?nonce:\s?(\d+)/#)?.output.1)
            let nonceValue: UInt64 = try XCTUnwrap(UInt64(nonceString))

            // Get obfuscated bytes
            let obfuscatedBytes = try obfuscatedString
                // Get matches for all `0xFF`
                .matches(of: /0x([0-9a-fA-F]{1,2})/)
                // Convert to a byte
                .map { match in try XCTUnwrap(UInt8(match.output.1, radix: 16)) }

            let deobfuscatedData = try crypter.deobfuscate(Data(obfuscatedBytes), nonce: nonceValue)

            let deobfuscatedValue = try XCTUnwrap(String(bytes: deobfuscatedData, encoding: .utf8))

            XCTAssertEqual(deobfuscatedValue, "\"\(value)\"")
        }
    }
}
