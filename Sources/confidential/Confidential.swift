import ArgumentParser

@main
struct Confidential: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "confidential",
        abstract: "A command-line tool to obfuscate secret literals embedded in Swift project.",
        subcommands: [
            Obfuscate.self
        ],
        defaultSubcommand: Obfuscate.self
    )
}
