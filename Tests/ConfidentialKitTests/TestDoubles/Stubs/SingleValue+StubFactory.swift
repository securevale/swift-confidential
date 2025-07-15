import ConfidentialKit
import Foundation

typealias SingleValue = Obfuscation.SupportedDataTypes.SingleValue

extension SingleValue {

    enum StubFactory {

        static func makeSecretMessage() -> SingleValue {
            "Secret message 🔐"
        }

        static func makeSecretMessageData() -> Data {
            .init(makeSecretMessage().utf8)
        }
    }
}
