import ConfidentialCore
import Foundation

protocol DataObfuscationStep {
    func obfuscate(_ data: Data, nonce: Obfuscation.Nonce) throws -> Data
}
