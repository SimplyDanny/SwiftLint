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
            Example("var i: Int { get throws { 1 }}"),
            Example(
                """
                struct S {
                    init() throws {}
                    subscript() throws -> Int { 1 }
                }
                """),
            Example("let f: () throws -> Void = {}"),
            Example("func f(_ g: () throws -> Void) rethrows {}"),
        ],
        corrections: [
            Example("func f() throws {}"):
                Example("func f() throws(any Error) {}"),
        ]
    )
}

private extension ImplicitThrownTypeRule {
    final class Visitor: ViolationsSyntaxVisitor<ConfigurationType> {
        override func visitPost(_ node: TokenSyntax) {
            guard node.tokenKind == .keyword(.throws),
                  node.nextToken(viewMode: .sourceAccurate)?.tokenKind != .leftParen else {
                return
            }
            violations.append(
                .init(
                    position: node.positionAfterSkippingLeadingTrivia,
                    correction: .init(
                        start: node.endPositionBeforeTrailingTrivia,
                        end: node.endPositionBeforeTrailingTrivia,
                        replacement: "(any Error)")))
        }
    }
}
