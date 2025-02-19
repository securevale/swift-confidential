@testable import ConfidentialCore

extension SourceSpecification {

    enum StubFactory {

        static func makeSpecification(
            algorithm: SourceSpecification.Algorithm = [],
            experimentalMode: Bool = false,
            internalImport: Bool = false,
            secrets: SourceSpecification.Secrets = [:]
        ) -> SourceSpecification {
            .init(
                algorithm: algorithm,
                experimentalMode: experimentalMode,
                internalImport: internalImport,
                secrets: secrets
            )
        }
    }
}
