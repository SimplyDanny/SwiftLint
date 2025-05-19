import SwiftLintCore
import SwiftSyntax

@SwiftSyntaxRule(correctable: true, optIn: true)
struct ImplicitThrownTypeRule: Rule {
    var configuration = SeverityConfiguration<Self>(.warning)

    static let description = RuleDescription(
        identifier: "implicit_thrown_type",
        name: "Implicit Thrown Type",
        description: "Function should not throw implicit error types",
        kind: .lint,
        nonTriggeringExamples: [
            Example("func f() {}"),
            Example("func f() throws(E) {}"),
        ],
        triggeringExamples: [
            Example("func f() throws {}"),
        ],
        corrections: [
            Example("func f() throws {}"):
                Example("func f() throws(any Error) {}"),
        ]
    )
}

private extension ImplicitThrownTypeRule {
    final class Visitor: ViolationsSyntaxVisitor<ConfigurationType> {

    }
}
