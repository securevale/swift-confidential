@testable import ConfidentialCore
import ConfidentialKit
import Foundation

extension SourceSpecification.Secret {

    enum StubFactory {

        static func makeInternalSecret(
            named name: String = "secret",
            data: Data = .init(),
            nonce: Obfuscation.Nonce = .zero
        ) -> SourceSpecification.Secret {
            makeSecret(
                accessModifier: .internal,
                name: name,
                data: data,
                nonce: nonce
            )
        }

        static func makePublicSecret(
            named name: String = "secret",
            data: Data = .init(),
            nonce: Obfuscation.Nonce = .zero
        ) -> SourceSpecification.Secret {
            makeSecret(
                accessModifier: .public,
                name: name,
                data: data,
                nonce: nonce
            )
        }

        static func makeSecret(
            from secret: Configuration.Secret,
            using encoder: any DataEncoder,
            accessModifier: (String?) -> SourceSpecification.Secret.AccessModifier = {
                .init(rawValue: $0 ?? "") ?? .internal
            },
            nonce: Obfuscation.Nonce = .zero
        ) throws -> SourceSpecification.Secret {
            makeSecret(
                accessModifier: accessModifier(secret.accessModifier),
                name: secret.name,
                data: try encoder.encode(secret.value.underlyingValue),
                nonce: nonce
            )
        }

        private static func makeSecret(
            accessModifier: SourceSpecification.Secret.AccessModifier,
            name: String,
            data: Data,
            nonce: Obfuscation.Nonce
        ) -> SourceSpecification.Secret {
            .init(
                accessModifier: accessModifier,
                name: name,
                data: data,
                nonce: nonce,
                dataAccessWrapperInfo: .init(typeInfo: TypeInfo(of: Any.self), arguments: [])
            )
        }
    }
}
