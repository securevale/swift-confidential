@testable import ConfidentialCore

extension SourceSpecification {

    enum StubFactory {

        static func makeSpecification(
            algorithm: SourceSpecification.Algorithm = [],
            importAttribute: SourceSpecification.ImportAttribute = .default,
            secrets: SourceSpecification.Secrets = [:]
        ) -> SourceSpecification {
            .init(
                algorithm: algorithm,
                importAttribute: importAttribute,
                secrets: secrets
            )
        }
    }
}
