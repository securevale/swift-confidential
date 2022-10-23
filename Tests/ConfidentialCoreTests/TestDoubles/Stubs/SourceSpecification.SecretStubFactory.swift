@testable import ConfidentialCore
import Foundation

extension SourceSpecification.Secret {

    enum StubFactory {

        static func makeInternalSecret(named name: String = "secret", with data: Data = .init()) -> SourceSpecification.Secret {
            makeSecret(
                accessModifier: .internal,
                name: name,
                data: data
            )
        }

        static func makePublicSecret(named name: String = "secret", with data: Data = .init()) -> SourceSpecification.Secret {
            makeSecret(
                accessModifier: .public,
                name: name,
                data: data
            )
        }

        static func makeSecret(
            from secret: Configuration.Secret,
            using encoder: DataEncoder,
            accessModifier: (String?) -> SourceSpecification.Secret.AccessModifier = {
                .init(rawValue: $0 ?? "") ?? .internal
            }
        ) throws -> SourceSpecification.Secret {
            makeSecret(
                accessModifier: accessModifier(secret.accessModifier),
                name: secret.name,
                data: try encoder.encode(secret.value.underlyingValue)
            )
        }

        private static func makeSecret(
            accessModifier: SourceSpecification.Secret.AccessModifier,
            name: String,
            data: Data
        ) -> SourceSpecification.Secret {
            .init(
                accessModifier: accessModifier,
                name: name,
                data: data,
                dataAccessWrapperInfo: .init(typeInfo: TypeInfo(of: Any.self), arguments: [])
            )
        }
    }
}
