import ConfidentialCore
import Foundation
import Parsing
import Yams

/// Obfuscates a source file based on a configuration.
public enum ConfidentialObfuscator {
    /// Creates a string with obfuscated source code based on a given configuration data.
    ///
    /// - Parameters:
    ///   - configurationData: The `Data` contents of a YAML file containing the configuration.
    /// - Returns: A string with obfuscated source code.
    /// - Throws: An error if the configuration is invalid or the obfuscation fails.
    public static func obfuscate(configurationData: Data) throws -> String {
        let configuration: Configuration = try YAMLDecoder().decode(Configuration.self, from: configurationData)

        var sourceFileSpec: SourceFileSpec = try Parsing.Parsers.ModelTransform.SourceFileSpec()
            .parse(configuration)

        try SourceObfuscator().obfuscate(&sourceFileSpec)

        let sourceFileText: SourceFileText = try Parsing.Parsers.CodeGeneration.SourceFile()
            .parse(&sourceFileSpec)

        return sourceFileText.text()
    }
}
