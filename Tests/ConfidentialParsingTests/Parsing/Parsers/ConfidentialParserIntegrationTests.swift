@testable import ConfidentialParsing
import XCTest

final class ConfidentialParserIntegrationTests: XCTestCase {

    private typealias SUT = ConfidentialParser<AnySourceFileSpecParser, AnySourceFileParser>

    func test_givenYAMLEncodedConfiguration_whenParse_thenReturnsExpectedSourceFileTextAndInputIsConsumed() throws {
        // given
        var input = Data(
            """
            algorithm: random
            defaultNamespace: create Secrets
            secrets:
              - name: apiKey
                value: 214C1E2E-A87E-4460-8205-4562FDF54D1C
                accessModifier: package
                algorithm:
                  - encrypt using chacha20-poly
              - name: suspiciousDynamicLibraries
                value:
                  - Substrate
                  - Substitute
                  - FridaGadget
              - name: suspiciousFilePaths
                value:
                  - /.installed_unc0ver
                  - /usr/sbin/frida-server
                  - /private/var/lib/cydia
            """.utf8
        )

        // when
        let sourceFileText = try SUT().parse(&input)

        // then
        XCTAssertEqual(
            SourceFileText(
                from: """
                    import ConfidentialKit
                    
                    package enum Secrets {
                    
                        package static #Obfuscate(algorithm: .custom([.encrypt(algorithm: .chaChaPoly)])) {
                            let apiKey = "214C1E2E-A87E-4460-8205-4562FDF54D1C"
                        }
                    
                        internal static #Obfuscate(algorithm: .random) {
                            let suspiciousDynamicLibraries = ["Substrate", "Substitute", "FridaGadget"]
                            let suspiciousFilePaths = ["/.installed_unc0ver", "/usr/sbin/frida-server", "/private/var/lib/cydia"]
                        }
                    }
                    """
            ),
            sourceFileText
        )
        XCTAssertTrue(input.isEmpty)
    }
}
