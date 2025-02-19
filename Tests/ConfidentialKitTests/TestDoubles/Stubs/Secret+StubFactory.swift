import ConfidentialKit
import Foundation

extension Obfuscation.Secret {

    enum StubFactory {

        static func makeJSONEncodedSecret(
            with singleValue: SingleValue,
            nonce: Obfuscation.Nonce
        ) -> Obfuscation.Secret {
            .init(data: try! JSONEncoder().encode(singleValue).map { $0 }, nonce: nonce)
        }
    }
}
