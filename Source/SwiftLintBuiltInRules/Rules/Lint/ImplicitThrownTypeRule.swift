import SwiftLintCore
import SwiftSyntax

@SwiftSyntaxRule(correctable: true, optIn: true)
struct ImplicitThrownTypeRule: Rule {
    var configuration = SeverityConfiguration<Self>(.warning)

    static let description = RuleDescription(
        identifier: "implicit_thrown_type",
        name: "Implicit Thrown Type",
        description: "",
        kind: .lint,
        nonTriggeringExamples: [
            Example(""),
        ],
        triggeringExamples: [
            Example(""),
        ],
        corrections: [
            Example(""):
                Example(""),
        ]
    )
}

private extension ImplicitThrownTypeRule {
    final class Visitor: ViolationsSyntaxVisitor<ConfigurationType> {

    }
}
