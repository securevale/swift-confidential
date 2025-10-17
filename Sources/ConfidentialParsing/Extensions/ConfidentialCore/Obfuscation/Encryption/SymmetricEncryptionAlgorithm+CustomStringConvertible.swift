import ConfidentialCore

extension Obfuscation.Encryption.SymmetricEncryptionAlgorithm: Swift.CustomStringConvertible {

    public var description: String {
        switch self {
        case .aes128GCM:
            return "aes-128-gcm"
        case .aes192GCM:
            return "aes-192-gcm"
        case .aes256GCM:
            return "aes-256-gcm"
        case .chaChaPoly:
            return "chacha20-poly"
        }
    }
}
