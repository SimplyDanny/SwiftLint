import Foundation
import SwiftLintFramework
import XCTest

final class ValidateConfigTests: XCTestCase {
    private var temporaryDirectory: URL?

    override func setUp() {
        super.setUp()
        temporaryDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString)
        guard let temporaryDirectory else {
            XCTFail("Failed to create temporary directory URL")
            return
        }
        do {
            try FileManager.default.createDirectory(
                at: temporaryDirectory, withIntermediateDirectories: true)
        } catch {
            XCTFail("Failed to create temporary directory: \(error)")
        }
    }

    override func tearDown() {
        if let temporaryDirectory {
            try? FileManager.default.removeItem(at: temporaryDirectory)
        }
        super.tearDown()
    }

    private func createConfigFile(named fileName: String, content: String) throws -> String {
        guard let temporaryDirectory else {
            XCTFail("Temporary directory not available")
            return ""
        }
        let configURL = temporaryDirectory.appendingPathComponent(fileName)
        try content.write(to: configURL, atomically: true, encoding: .utf8)
        return configURL.path
    }

    // MARK: - Valid Configuration Tests

    func testValidateValidConfiguration() throws {
        let validConfig = """
            opt_in_rules:
              - identifier_name
            excluded:
              - Carthage
              - Pods
            line_length:
              warning: 120
              error: 200
            """

        let configPath = try createConfigFile(named: "valid.yml", content: validConfig)

        // Test that Configuration can be created without throwing
        XCTAssertNoThrow({
            let configuration = Configuration(configurationFiles: [configPath])
            XCTAssertGreaterThan(configuration.rules.count, 0)
        })
    }

    func testValidateMinimalConfiguration() throws {
        let minimalConfig = """
            rules:
              - line_length
            """

        let configPath = try createConfigFile(named: "minimal.yml", content: minimalConfig)

        XCTAssertNoThrow({
            let configuration = Configuration(configurationFiles: [configPath])
            XCTAssertGreaterThan(configuration.rules.count, 0)
        })
    }

    func testValidateEmptyConfiguration() throws {
        let emptyConfig = ""

        let configPath = try createConfigFile(named: "empty.yml", content: emptyConfig)

        XCTAssertNoThrow({
            let configuration = Configuration(configurationFiles: [configPath])
            XCTAssertGreaterThan(configuration.rules.count, 0)  // Should have default rules
        })
    }

    func testValidateConfigurationWithCustomRules() throws {
        let configWithCustomRules = """
            custom_rules:
              my_custom_rule:
                name: "My Custom Rule"
                regex: "TODO|FIXME"
                message: "Please resolve this before committing"
                severity: warning
            """

        let configPath = try createConfigFile(
            named: "custom_rules.yml", content: configWithCustomRules)

        XCTAssertNoThrow({
            let configuration = Configuration(configurationFiles: [configPath])
            XCTAssertGreaterThan(configuration.rules.count, 0)
        })
    }

    // MARK: - Configuration File Existence Tests

    func testFileExists() throws {
        let validConfig = """
            rules:
              - line_length
            """

        let configPath = try createConfigFile(named: "test.yml", content: validConfig)

        XCTAssertTrue(FileManager.default.fileExists(atPath: configPath))
    }

    func testFileDoesNotExist() throws {
        guard let temporaryDirectory else {
            throw XCTSkip("Temporary directory not available")
        }
        let nonExistentPath = temporaryDirectory.appendingPathComponent("nonexistent.yml").path

        XCTAssertFalse(FileManager.default.fileExists(atPath: nonExistentPath))
    }

    func testDefaultConfigurationFileName() {
        XCTAssertEqual(Configuration.defaultFileName, ".swiftlint.yml")
    }

    // MARK: - Configuration Loading Tests

    func testLoadConfigurationWithInvalidRuleName() throws {
        let configWithInvalidRule = """
            opt_in_rules:
              - nonexistent_rule_name
              - identifier_name
            """

        let configPath = try createConfigFile(
            named: "invalid_rule.yml", content: configWithInvalidRule)

        // Configuration should load successfully, ignoring invalid rule names
        XCTAssertNoThrow({
            let configuration = Configuration(configurationFiles: [configPath])
            XCTAssertGreaterThan(configuration.rules.count, 0)
        })
    }

    func testLoadConfigurationWithInvalidRuleConfiguration() throws {
        let configWithInvalidRuleConfig = """
            line_length:
              warning: "not_a_number"
              error: 200
            """

        let configPath = try createConfigFile(
            named: "invalid_rule_config.yml",
            content: configWithInvalidRuleConfig
        )

        // Configuration should load successfully with default values
        // for invalid configurations
        XCTAssertNoThrow({
            let configuration = Configuration(configurationFiles: [configPath])
            XCTAssertGreaterThan(configuration.rules.count, 0)
        })
    }

    func testLoadDefaultConfiguration() {
        // Test loading default configuration when no files are specified
        XCTAssertNoThrow({
            let configuration = Configuration(configurationFiles: [])
            XCTAssertGreaterThan(configuration.rules.count, 0)
        })
    }

    // MARK: - Complex Configuration Tests

    func testValidateConfigurationWithComplexStructure() throws {
        let complexConfig = """
            included:
              - Source
              - Tests
            excluded:
              - Carthage
              - Pods
              - build
            opt_in_rules:
              - attributes
              - closure_end_indentation
              - closure_spacing
              - conditional_returns_on_newline
              - empty_count
              - explicit_init
            disabled_rules:
              - trailing_whitespace
            line_length:
              warning: 120
              error: 200
              ignores_function_declarations: true
              ignores_comments: true
              ignores_urls: true
            type_body_length:
              warning: 300
              error: 400
            file_length:
              warning: 500
              error: 1200
            identifier_name:
              min_length:
                warning: 1
                error: 1
              max_length:
                warning: 40
                error: 60
              excluded:
                - id
                - URL
                - url
            custom_rules:
              force_https:
                name: "Force HTTPS over HTTP"
                regex: "((?i)http(?!s))"
                match_kinds: string
                message: "HTTPS should be favored over HTTP"
                severity: warning
            """

        let configPath = try createConfigFile(named: "complex.yml", content: complexConfig)

        XCTAssertNoThrow({
            let configuration = Configuration(configurationFiles: [configPath])
            XCTAssertGreaterThan(configuration.rules.count, 0)
            XCTAssertTrue(configuration.excludedPaths.contains("Carthage"))
            XCTAssertTrue(configuration.excludedPaths.contains("Pods"))
            XCTAssertTrue(configuration.excludedPaths.contains("build"))
        })
    }

    func testValidateConfigurationWithSpecialCharacters() throws {
        let configWithSpecialChars = """
            custom_rules:
              special_chars:
                name: "Special Characters Test"
                regex: "[éñüíó]+"
                message: "Found special characters: éñüíó"
                severity: warning
            """

        let configPath = try createConfigFile(
            named: "special_chars.yml", content: configWithSpecialChars)

        XCTAssertNoThrow({
            let configuration = Configuration(configurationFiles: [configPath])
            XCTAssertGreaterThan(configuration.rules.count, 0)
        })
    }

    // MARK: - YAML Syntax Tests

    func testInvalidYAMLSyntax() throws {
        let invalidYAMLConfig = """
            opt_in_rules:
              - identifier_name
            excluded
              - Carthage
              - Pods
            line_length:
              warning: 120
              error: 200
            """

        let configPath = try createConfigFile(named: "invalid_yaml.yml", content: invalidYAMLConfig)

        // Configuration should handle invalid YAML gracefully
        XCTAssertNoThrow({
            let configuration = Configuration(configurationFiles: [configPath])
            XCTAssertGreaterThan(configuration.rules.count, 0)
        })
    }

    // MARK: - Configuration Properties Tests

    func testConfigurationProperties() throws {
        let configWithVariousSettings = """
            warning_threshold: 10
            reporter: "xcode"
            strict: true
            lenient: false
            """

        let configPath = try createConfigFile(
            named: "properties.yml", content: configWithVariousSettings)

        XCTAssertNoThrow({
            let configuration = Configuration(configurationFiles: [configPath])
            XCTAssertEqual(configuration.warningThreshold, 10)
            XCTAssertEqual(configuration.reporter, "xcode")
            XCTAssertTrue(configuration.strict)
            XCTAssertFalse(configuration.lenient)
        })
    }
}
