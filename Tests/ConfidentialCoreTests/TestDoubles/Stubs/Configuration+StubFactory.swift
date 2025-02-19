@testable import ConfidentialCore

extension Configuration {

    enum StubFactory {

        static func makeConfiguration(
            algorithm: ArraySlice<String> = [],
            experimentalMode: Bool = false,
            secrets: ArraySlice<Configuration.Secret> = []
        ) -> Configuration {
            .init(
                algorithm: algorithm,
                defaultAccessModifier: .none,
                defaultNamespace: .none,
                experimentalMode: experimentalMode,
                internalImport: .none,
                secrets: secrets
            )
        }
    }
}
