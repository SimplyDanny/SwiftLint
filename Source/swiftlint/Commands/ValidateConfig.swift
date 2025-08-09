import ArgumentParser
import Foundation
import SwiftLintFramework

extension SwiftLint {
    struct ValidateConfig: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "validate-config",
            abstract: "Validate a SwiftLint configuration file"
        )

        @Option(help: "The path to a SwiftLint configuration file to validate.")
        var config: String?

        func run() throws {
            let configurationFile = try checkConfigurationFileExists(config ?? Configuration.defaultFileName)
            _ = Configuration(configurationFiles: [configurationFile])

            print("✅ Configuration validation successful. No issues found.")
        }

        private func checkConfigurationFileExists(_ file: String) throws -> String {
            if FileManager.default.fileExists(atPath: file) {
                return file
            }
            print("❌ Configuration validation failed. Configuration file\(file) not found.")
            throw ExitCode.failure
        }
    }
}
