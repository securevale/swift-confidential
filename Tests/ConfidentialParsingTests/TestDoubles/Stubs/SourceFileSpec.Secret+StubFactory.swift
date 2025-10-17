@testable import ConfidentialParsing

extension SourceFileSpec.Secret {

    enum StubFactory {

        static func makeInternalSecret(
            named name: String = "secret",
            algorithm: SourceFileSpec.Secret.Algorithm = .random,
            value: SourceFileSpec.Secret.Value = .string("")
        ) -> SourceFileSpec.Secret {
            .init(
                accessModifier: .internal,
                algorithm: algorithm,
                name: name,
                value: value
            )
        }

        static func makePackageSecret(
            named name: String = "secret",
            algorithm: SourceFileSpec.Secret.Algorithm = .random,
            value: SourceFileSpec.Secret.Value = .string("")
        ) -> SourceFileSpec.Secret {
            .init(
                accessModifier: .package,
                algorithm: algorithm,
                name: name,
                value: value
            )
        }

        static func makePublicSecret(
            named name: String = "secret",
            algorithm: SourceFileSpec.Secret.Algorithm = .random,
            value: SourceFileSpec.Secret.Value = .string("")
        ) -> SourceFileSpec.Secret {
            .init(
                accessModifier: .public,
                algorithm: algorithm,
                name: name,
                value: value
            )
        }
    }
}
