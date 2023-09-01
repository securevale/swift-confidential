@testable import ConfidentialCore

extension Configuration {

    enum StubFactory {

        static func makeConfiguration(
            algorithm: ArraySlice<String> = [],
            secrets: ArraySlice<Configuration.Secret> = []
        ) -> Configuration {
            .init(
                algorithm: algorithm,
                defaultAccessModifier: .none,
                defaultNamespace: .none,
                implementationOnlyImport: .none,
                secrets: secrets
            )
        }
    }
}
