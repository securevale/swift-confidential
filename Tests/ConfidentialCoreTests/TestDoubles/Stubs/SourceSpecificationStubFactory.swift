@testable import ConfidentialCore

extension SourceSpecification {

    enum StubFactory {

        static func makeSpecification(
            algorithm: SourceSpecification.Algorithm = [],
            secrets: SourceSpecification.Secrets = [:]
        ) -> SourceSpecification {
            .init(algorithm: algorithm, secrets: secrets)
        }
    }
}
