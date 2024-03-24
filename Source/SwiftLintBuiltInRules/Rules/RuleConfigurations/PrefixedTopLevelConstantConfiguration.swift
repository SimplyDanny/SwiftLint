import SwiftLintCore

@AutoApply
struct PrefixedTopLevelConstantConfiguration: SeverityBasedRuleConfiguration {
    typealias Parent = PrefixedTopLevelConstantRule

    @ConfigurationElement(key: "severity")
    private(set) var severity = SeverityConfiguration<Parent>(.warning)
    @ConfigurationElement(key: "only_private")
    private(set) var onlyPrivateMembers = false
}
