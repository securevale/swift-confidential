@testable import ConfidentialCore
import Foundation

extension SourceSpecification.Secret {

    enum StubFactory {

        static func makeSecret(named name: String = "secret", with data: Data = .init()) -> SourceSpecification.Secret {
            .init(
                name: name,
                data: data,
                dataAccessWrapperInfo: .init(typeInfo: TypeInfo(of: Any.self), arguments: [])
            )
        }

        static func makeSecret(from secret: Configuration.Secret, using encoder: DataEncoder) throws -> SourceSpecification.Secret {
            .init(
                name: secret.name,
                data: try encoder.encode(secret.value.underlyingValue),
                dataAccessWrapperInfo: .init(typeInfo: TypeInfo(of: Any.self), arguments: [])
            )
        }
    }
}
