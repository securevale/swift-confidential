@testable import ConfidentialCore

extension SourceFileSpec {

    enum StubFactory {

        static func makeSpec(
            algorithm: SourceFileSpec.Algorithm = [],
            experimentalMode: Bool = false,
            internalImport: Bool = false,
            secrets: SourceFileSpec.Secrets = [:]
        ) -> SourceFileSpec {
            .init(
                algorithm: algorithm,
                experimentalMode: experimentalMode,
                internalImport: internalImport,
                secrets: secrets
            )
        }
    }
}
