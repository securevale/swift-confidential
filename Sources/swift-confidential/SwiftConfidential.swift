import ArgumentParser

@main
struct SwiftConfidential: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "swift-confidential",
        abstract: "A command-line tool to obfuscate secret literals embedded in Swift project.",
        subcommands: [
            Obfuscate.self
        ],
        defaultSubcommand: Obfuscate.self
    )
}
