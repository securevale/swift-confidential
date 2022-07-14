import Foundation

protocol DataObfuscationStep {
    func obfuscate(_ data: Data) throws -> Data
}
