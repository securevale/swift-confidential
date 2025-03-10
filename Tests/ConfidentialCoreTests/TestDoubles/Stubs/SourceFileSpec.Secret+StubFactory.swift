@testable import ConfidentialCore
import ConfidentialKit
import Foundation

extension SourceFileSpec.Secret {

    enum StubFactory {

        static func makeInternalSecret(
            named name: String = "secret",
            data: Data = .init(),
            nonce: Obfuscation.Nonce = .zero
        ) -> SourceFileSpec.Secret {
            makeSecret(
                accessModifier: .internal,
                name: name,
                data: data,
                nonce: nonce
            )
        }

        static func makePackageSecret(
            named name: String = "secret",
            data: Data = .init(),
            nonce: Obfuscation.Nonce = .zero
        ) -> SourceFileSpec.Secret {
            makeSecret(
                accessModifier: .package,
                name: name,
                data: data,
                nonce: nonce
            )
        }

        static func makePublicSecret(
            named name: String = "secret",
            data: Data = .init(),
            nonce: Obfuscation.Nonce = .zero
        ) -> SourceFileSpec.Secret {
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
            accessModifier: (String?) -> SourceFileSpec.Secret.AccessModifier = {
                .init(rawValue: $0 ?? "") ?? .internal
            },
            nonce: Obfuscation.Nonce = .zero
        ) throws -> SourceFileSpec.Secret {
            makeSecret(
                accessModifier: accessModifier(secret.accessModifier),
                name: secret.name,
                data: try encoder.encode(secret.value.underlyingValue),
                nonce: nonce
            )
        }

        private static func makeSecret(
            accessModifier: SourceFileSpec.Secret.AccessModifier,
            name: String,
            data: Data,
            nonce: Obfuscation.Nonce
        ) -> SourceFileSpec.Secret {
            .init(
                accessModifier: accessModifier,
                name: name,
                data: data,
                nonce: nonce,
                dataProjectionAttribute: .init(
                    name: "Test",
                    arguments: [],
                    isPropertyWrapper: true
                )
            )
        }
    }
}
