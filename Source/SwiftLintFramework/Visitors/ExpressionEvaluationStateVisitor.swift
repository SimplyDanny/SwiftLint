import SwiftSyntax

enum ExpressionType: Equatable {
    case boolean(Bool)
    case string(String)
    case integer(Int)
    case float(Double)
    case `nil`
}

enum ExpressionEvaluationState: Equatable {
    case constant(ExpressionType)
    case dynamic

    fileprivate static prefix func !(operand: Self) -> Self {
        if case .constant(.boolean(let value)) = operand {
            return .constant(.boolean(!value))
        }
        return .dynamic
    }

    fileprivate static func &&(lhs: Self, rhs: Self) -> Self {
        if case .constant(.boolean(let value)) = lhs, !value {
            return .constant(.boolean(false))
        }
        if case .constant(.boolean(let value)) = rhs, !value {
            return .constant(.boolean(false))
        }
        return .dynamic
    }

    fileprivate static func ||(lhs: Self, rhs: Self) -> Self {
        if case .constant(.boolean(let value)) = lhs, value {
            return .constant(.boolean(true))
        }
        if case .constant(.boolean(let value)) = rhs, value {
            return .constant(.boolean(true))
        }
        return .dynamic
    }
}

class ExpressionEvaluationStateVisitor: SyntaxTransformVisitor {
    typealias State = ExpressionEvaluationState
    typealias ResultType = State // Protocol conformance

    func visitAny(_ node: Syntax) -> ExpressionEvaluationState {
        fatalError("Missing implementation for syntax kind \(node.kind)")
    }

    func visit(_ node: BooleanLiteralExprSyntax) -> State {
        .constant(.boolean(Bool(node.booleanLiteral.text)!))
    }

    func visit(_ node: StringLiteralExprSyntax) -> State {
        .constant(.string(""))
    }

    func visit(_ node: IntegerLiteralExprSyntax) -> State {
        .constant(.integer(Int(node.digits.text)!))
    }

    func visit(_ node: FloatLiteralExprSyntax) -> State {
        .constant(.float(Double(node.floatingDigits.text)!))
    }

    func visit(_ node: NilLiteralExprSyntax) -> State {
        .constant(.nil)
    }

    func visit(_ node: IdentifierExprSyntax) -> State {
        .dynamic
    }

    func visit(_ node: TupleExprSyntax) -> State {
        // All tuples in an expression context must be bracket expressions and can be unwrapped (hopefully).
        visit(node.elementList.onlyElement!.expression)
    }

    func visit(_ node: PrefixOperatorExprSyntax) -> State {
        let operand = visit(node.postfixExpression)
        switch node.operatorToken?.text {
        case "!":
            return !operand
        default:
            return .dynamic
        }
    }

    func visit(_ node: InfixOperatorExprSyntax) -> State {
        if let op = node.operatorOperand.as(BinaryOperatorExprSyntax.self) {
            let left = visit(node.leftOperand)
            let right = visit(node.rightOperand)
            switch op.operatorToken.text {
            case "&&":
                return left && right
            case "||":
                return left || right
            default:
                return .dynamic
            }
        }
        return .dynamic
    }
}
