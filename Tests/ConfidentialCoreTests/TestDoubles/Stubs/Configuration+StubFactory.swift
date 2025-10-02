@testable import ConfidentialCore

extension Configuration {

    enum StubFactory {

        static func makeConfiguration(
            algorithm: Configuration.Algorithm? = .none,
            secrets: ArraySlice<Configuration.Secret> = []
        ) -> Configuration {
            .init(
                algorithm: algorithm,
                defaultAccessModifier: .none,
                defaultNamespace: .none,
                experimentalMode: false,
                internalImport: .none,
                secrets: secrets
            )
        }
    }
}
