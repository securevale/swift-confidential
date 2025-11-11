import ArgumentParser
import ConfidentialParsing
import Foundation

extension SwiftConfidential {

    struct Obfuscate: ParsableCommand {

        static let configuration = CommandConfiguration(
            commandName: "obfuscate",
            abstract: "Obfuscate secret literals.",
            discussion: """
                        The generated Swift code provides accessors for each secret literal, \
                        grouped into namespaces as defined in configuration file. \
                        The accessor allows for retrieving a deobfuscated literal at \
                        runtime.
                        """
        )

        @Option(
            name: [.long, .short],
            help: "The path to a Confidential configuration file.",
            transform: URL.init(fileURLWithPath:)
        )
        var configuration: URL

        @Option(
            name: [.long, .short],
            help: "The path to an output source file where the generated Swift code is to be written.",
            transform: URL.init(fileURLWithPath:)
        )
        var output: URL

        private var fileManager: FileManager { .default }

        mutating func run() throws {
            guard fileManager.isReadableFile(atPath: configuration.path) else {
                throw RuntimeError(description: #"Unable to read configuration file at "\#(configuration.path)""#)
            }

            let configurationYAML = try Data(contentsOf: configuration)

            let sourceFileText = try ConfidentialParser()
                .parse(configurationYAML)

            guard fileManager.createFile(atPath: output.path, contents: .none) else {
                throw RuntimeError(description: #"Failed to create output file at "\#(output.path)""#)
            }

            try sourceFileText.write(to: output)
        }
    }
}
