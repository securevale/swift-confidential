@testable import ConfidentialCore

extension SourceSpecification {

    enum StubFactory {

        static func makeSpecification(
            algorithm: SourceSpecification.Algorithm = [],
            implementationOnlyImport: Bool = false,
            secrets: SourceSpecification.Secrets = [:]
        ) -> SourceSpecification {
            .init(
                algorithm: algorithm,
                implementationOnlyImport: implementationOnlyImport,
                secrets: secrets
            )
        }
    }
}
