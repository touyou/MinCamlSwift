//
//  AST.swift
//  MinCamlSwiftPackageDescription
//
//  Created by 藤井陽介 on 2017/11/13.
//

import Foundation

/// A node in the source codes abstract syntax tree (AST)
public class ASTNode: CustomDebugStringConvertible {
    
    /// The range in the source code which this node represents
    public let sourceRange: SourceRange
    
    public var debugDescription: String {
        
        // TODO: ASTPrinter
    }
    
    init(sourceRange: SourceRange) {
        
        self.sourceRange = sourceRange
    }
}

/// Represents a source file with its expressions
/// (expression; expression; expression; ...) = expressions
public class ASTRoot: ASTNode {
    
    public let expressions: [Expression]
    
    init(expressions: [Expression], sourceRange: SourceRange) {
        
        self.expressions = expressions
        super.init(sourceRange: sourceRange)
    }
}

// In min-caml, all syntax can be expressions because min-caml is functional programming language.

/// Abstract base class for expressions in the AST
///
/// In contrast to statements, expressions calculate values
public class Expression: ASTNode {
}

// MARK: - Expression

// Unit is equal to Expression

/// Boolean literal. i.e. true and false
public class BooleanLiteralExpression: Expression {
    
    /// The value of the literal
    public let value: Bool
    
    init(value: Bool, sourceRange: SourceRange) {
        
        self.value = value
        super.init(sourceRange: sourceRange)
    }
}

/// Integer literal. i.e 4, 1023
public class IntegerLiteralExpression: Expression {
    
    /// The value of the literal
    public let value: Int
    
    init(value: Int, sourceRange: SourceRange) {
        
        self.value = value
        super.init(sourceRange: sourceRange)
    }
}

/// Floating point number literal. i.e. 0.123, 3.1415
public class FloatLiteralExpression: Expression {
    
    /// The value of the literal
    public let value: Double
    
    init(value: Double, sourceRange: SourceRange) {
        
        self.value = value
        super.init(sourceRange: sourceRange)
    }
}

/// A single operator expression
/// operator like 'not' or '-'
public class SingleOperatorExpression: Expression {
    
    /// Enumeration of all the single operators supported by SingleOperatorExpression
    public enum Operator {
        case not
        case neg
        case fneg
        
        /// The name with which this operator is spellec out in the source code
        public var sourceCodeName: String {
            
            switch self {
            case .not:
                return "not"
            case .neg:
                return "-"
            case .fneg:
                return "-"
            }
        }
        
        /// The precedence of the operator, e.g. '*' has higher precedence than '+'.
        ///
        /// A higher precedence value means that the value should bind stronger than
        /// values with lower precedence
        ///
        var precedence: Int {
            
            switch self {
            case .not:
                return 10   // TODO: Think whether this is proper precedence or not
            case .neg:
                return 10   // Should have higher precedence than any binary operators
            case .fneg:
                return 10
            }
        }
    }
    
    /// The right-hand-side of the operator
    public let rhs: Expression
    /// The operator
    public let `operator`: Operator
    
    init(rhs: Expression, operator: Operator) {
        
        self.rhs = rhs
        self.operator = `operator`
        // Temp source range
        super.init(sourceRange: self.rhs.sourceRange)
    }
}

/// A binary operator expression
/// operator like '+' or '<='
public class BinaryOperatorExpression: Expression {
    
    /// Enumeration of all the binary operators supported by BinaryOperatorExpression
    public enum Operator {
        case add
        case sub
        case mul
        case div
        case xor
        case or
        case and
        case sll
        case srl
        case fadd
        case fsub
        case fmul
        case fdiv
        case equal
        case lessOrEqual
        
        /// The name with which this operator is spellec out in the source code
        public var sourceCodeName: String {
            
            switch self {
            case .add:
                return "+"
            case .sub:
                return "-"
            case .mul:
                return "*"
            case .div:
                return "/"
            case .xor:
                return "lxor"
            case .or:
                return "lor"
            case .and:
                return "land"
            case .sll:
                return "lsl"
            case .srl:
                return "lsr"
            case .fadd:
                return "+."
            case .fsub:
                return "-."
            case .fmul:
                return "*."
            case .fdiv:
                return "/."
            case .equal:
                return "="
            case .lessOrEqual:
                return "<="
            }
        }
        
        /// The precedence of the operator, e.g. '*' has higher precedence than '+'.
        ///
        /// A higher precedence value means that the value should bind stronger than
        /// values with lower precedence
        var precedence: Int {
            
            switch self {
            case .add:
                return 3
            case .sub:
                return 3
            case .mul:
                return 4
            case .div:
                return 4
            case .xor:
                return 2
            case .or:
                return 2
            case .and:
                return 2
            case .sll:
                return 6
            case .srl:
                return 6
            case .fadd:
                return 3
            case .fsub:
                return 3
            case .fmul:
                return 4
            case .fdiv:
                return 4
            case .equal:
                return 1
            case .lessOrEqual:
                return 1
            }
        }
    }
    
    /// The left-hand-side of the operator
    public let lhs: Expression
    /// The right-hand-side of the operator
    public let rhs: Expression
    /// The operator to combine the two expressions
    public let `operator`: Operator
    
    init(lhs: Expression, rhs: Expression, operator: Operator) {
        
        self.lhs = lhs
        self.rhs = rhs
        self.operator = `operator`
        let sourceRange = SourceRange(start: self.lhs.sourceRange.start, end: self.rhs.sourceRange.end)
        super.init(sourceRange: sourceRange)
    }
}

/// An if expression in the AST
public class IfExpression: Expression {
    
    /// The condition to be evaluated to decide if the statement's body shall
    /// be executed
    public let condition: Expression
    /// The body to be executed only if the condition evaluates to true
    public let body: Expression
    /// The body of the else-clause if it existed
    public let elseBody: Expression?
    /// The source range of the `if` keyword
    public let ifRange: SourceRange
    /// The source range of the `else` keyword if it existed
    public let elseRange: SourceRange?
    
    /// Create a node in the AST representing an `if` expression
    ///
    /// - Parameters:
    ///     - condition: The condition to evaluate in order to determine if the if body shall be executed
    ///     - body: The body of the `if` statement
    ///     - elseBody: If the else statement has an `else` part, its body, otherwise `nil`
    ///     - ifRange: The source range of the `if` keyword
    ///     - elseRange: The source range of the `else` keyword, if present
    ///     - sourceRange: The source range of the entire statement
    public init(condition: Expression, body: Expression, elseBody: Expression?, ifRange: SourceRange, elseRange: SourceRange?, sourceRange: SourceRange) {
        
        self.condition = condition
        self.body = body
        self.elseBody = elseBody
        self.ifRange = ifRange
        self.elseRange = elseRange
        super.init(sourceRange: sourceRange)
    }
}

/// A let expression in the AST
/// Declaration of variable with expression
public class LetExpression: Expression {
    
    /// Name of expression
    public let name: String
    /// Type of expression
    public let type: Type
    /// Decralation expression
    public let body: Expression
    /// Children.
    public let nextBody: Expression?
    
    public init(name: String, type: Type, body: Expression, nextBody: Expression?, sourceRange: SourceRange) {
        
        self.name = name
        self.type = type
        self.body = body
        self.nextBody = nextBody
        super.init(sourceRange: sourceRange)
    }
}

/// A variable expresssion
public class VariableExpression: Expression {
    
    /// Name of variable
    public let name: String
    
    public init(name: String, sourceRange: SourceRange) {
        
        self.name = name
        super.init(sourceRange: sourceRange)
    }
}

/// A let rec expression in the AST
/// In min-caml, it declare a function.
public class LetRecExpression: Expression {
    
    /// For arguments
    public struct Arg {
        public let name: String
        public let type: Type
    }
    
    /// Function name
    public let name: String
    /// Return type
    public let type: Type
    /// Arguments
    public let arguments: [Arg]
    /// Body
    public let body: Expression
    /// Children.
    public let nextBody: Expression?
    
    public init(name: String, type: Type, arguments: [Arg], body: Expression, nextBody: Expression?, sourceRange: SourceRange) {
        
        self.name = name
        self.type = type
        self.arguments = arguments
        self.body = body
        self.nextBody = nextBody
        super.init(sourceRange: sourceRange)
    }
}
