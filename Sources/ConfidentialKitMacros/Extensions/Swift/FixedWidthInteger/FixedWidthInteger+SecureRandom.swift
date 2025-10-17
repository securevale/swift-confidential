import Foundation

extension FixedWidthInteger {

    typealias SecureRandomNumberSource = (inout [UInt8]) -> OSStatus

    static func secureRandom(
        using source: SecureRandomNumberSource = {
            SecRandomCopyBytes(kSecRandomDefault, $0.count, &$0)
        }
    ) throws -> Self {
        let count = MemoryLayout<Self>.stride
        var bytes = [UInt8](repeating: .zero, count: count)
        let status = source(&bytes)
        guard status == errSecSuccess else {
            let errorDescription = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error"
            throw NSError(
                domain: NSOSStatusErrorDomain,
                code: .init(status),
                userInfo: [NSLocalizedDescriptionKey: errorDescription]
            )
        }

        return bytes.withUnsafeBytes { $0.load(as: Self.self) }
    }
}
