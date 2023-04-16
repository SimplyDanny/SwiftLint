@testable import SwiftLintFramework
import SwiftOperators
import SwiftParser
import SwiftSyntax
import XCTest

class ExpressionEvaluationStateVisitorTests: XCTestCase {
    let testee = ExpressionEvaluationStateVisitor()

    func testBooleanConstantlyFalse() {
        [
            "false",
            "!true",
            "false && a",
            "false && false",
            "a && false",
            "false && false",
            "false && true",
            "(a && b) && false",
            "(1 < 2) && false"
        ].forEach { source in
            XCTAssertEqual(state(of: source), .constant(.boolean(false)))
        }
    }

    func testBooleanUndecidable() {
        [
            "true && a",
            "a && a",
            "a && true",
            "(a && b) && c"
        ].forEach { source in
            XCTAssertEqual(state(of: source), .dynamic)
        }
    }

    private func state(of source: ExprSyntax) -> ExpressionEvaluationState {
        let sequenceExpr = source.as(SequenceExprSyntax.self) ?? SequenceExprSyntax(elements: [source])
        let foldedExpr = try! OperatorTable.standardOperators.foldAll(sequenceExpr)
        return testee.visit(foldedExpr)
    }
}
