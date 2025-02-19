import ConfidentialKit

extension Obfuscation.Encryption.SymmetricEncryptionAlgorithm: Swift.CaseIterable {

    public static var allCases: [Self] {
        [
            .aes128GCM,
            .aes192GCM,
            .aes256GCM,
            .chaChaPoly
        ]
    }
}
