import ConfidentialCore
import Foundation

extension Obfuscation.Secret {

    enum StubFactory {

        static func makeJSONEncodedSecret(
            with string: String,
            nonce: Obfuscation.Nonce
        ) -> Obfuscation.Secret {
            .init(data: try! JSONEncoder().encode(string).map { $0 }, nonce: nonce)
        }
    }
}
