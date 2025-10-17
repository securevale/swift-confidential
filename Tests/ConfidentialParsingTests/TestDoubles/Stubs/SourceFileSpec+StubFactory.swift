@testable import ConfidentialParsing

extension SourceFileSpec {

    enum StubFactory {

        static func makeSpec(
            experimentalMode: Bool = false,
            internalImport: Bool = false,
            secrets: SourceFileSpec.Secrets = [:]
        ) -> SourceFileSpec {
            .init(
                experimentalMode: experimentalMode,
                internalImport: internalImport,
                secrets: secrets
            )
        }
    }
}
