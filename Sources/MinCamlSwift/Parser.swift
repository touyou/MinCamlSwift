//
//  Parser.swift
//  MinCamlSwiftPackageDescription
//
//  Created by 藤井陽介 on 2017/11/13.
//

import Foundation

// MARK: Parser

class Parser {
    
    /// The lexer that converts the source code into tokens
    private var lexer: Lexer!
    
    /// The token thant shall be parsed next
    public var nextToken: Token!
    
    /// The last token that was parsed
    private var lastToken: Token?
    
    public init() {
    }
    
    /// Parse the sourceCode of this parser into an abstract syntax tree (AST)
    ///
    /// - Parameter sourceFile: The source file to parse
    /// - Returns: The parsed abstract syntax tree
    /// - Throws: A CompilationError if compilation failed
    public static func parse(sourceFile: SourceFile) throws -> ASTRoot {
        
        let parser = Parser()
        return try paser.parse(sourceFile: sourceFile)
    }
    
    /// Parse the sourceCode of this parser into an abstract syntax tree (AST)
    ///
    /// - Parameter sourceFile: The source file to parse
    /// - Returns: The parsed abstract syntax tree
    /// - Throws: A CompilationError if compilation failed
    public func parse(sourceFile: SourceFile) throws -> ASTRoot {
        
        self.lexer = Lexer(sourceCode: sourceFile.sourceCode)
        
        self.nextToken = try lexer.nextToken()
        let startLoc = self.nextToken.sourceRange.start
        
        var expressions: [Expression] = []
        while nextToken.payload != .endOfFile {
            expressions.append(try parseExpression())
        }
        
        let endLoc = self.nextToken.sourceRange.start
        
        return ASTRoot(expressions: expressions, sourceRange: SourceRange(start: startLoc, end: endLoc))
    }
    
    /// Create a source range starting at the given location and ending at the current
    /// position
    ///
    /// - Parameter startingAt: The source location where the range shall start
    /// - Returns: A range starting at the given location and ending at the current token
    public func range(startingAt: SourceLoc) -> SourceRange {
        
        if let lastToken = lastToken {
            
            return SourceRange(start: startingAt, end: lastToken.sourceRange.end)
        } else {
            
            return SourceRange(start: startingAt, end: nextToken.sourceRange.start)
        }
    }
    
    /// Consume the next token and fill the nextToken variable with
    /// the upcoming token from the lexer
    ///
    /// - Returns: The token that has just been consumed
    /// - Throws: A CompilationError if the lexer failed to return the next token
    @discardableResult
    public func consumeToken() throws -> Token? {
        
        lastToken = nextToken
        nextToken = try self.lexer.nextToken()
        return lastToken
    }
    
    /// Parse the simple expression. Like simple_exp
    ///
    /// - Returns: The parsed expression
    /// - Throws: A CompilationError if compilation failed
    private func parseSimpleExpression() throws -> Expression? {
        
        switch nextToken.payload {
        case .leftParen:
            let startLoc = nextToken.sourceRange.start
            try consumeToken()
            if nextToken.payload == .rightParen {
                
                try consumeToken()
                return Expression(sourceRange: range(startingAt: startLoc))
            } else {
                
                let expression = try parseExpression()
                if nextToken.payload == .rightParen {
                    
                    return expression
                } else {
                    
                    throw CompilationError(sourceRange: range(startingAt: startLoc), errorMessage: "Expected ')'")
                }
            }
        case .boolean(let value):
            let sourceRange = nextToken.sourceRange
            try consumeToken()
            return BooleanLiteralExpression(value: value, sourceRange: sourceRange)
        case .integer(let value):
            let sourceRange = nextToken.sourceRange
            try consumeToken()
            return IntegerLiteralExpression(value: value, sourceRange: sourceRange)
        case .float(let value):
            let sourceRange = nextToken.sourceRange
            try consumeToken()
            return FloatLiteralExpression(value: value, sourceRange: sourceRange)
        case .identifier(let name):
            let sourceRange = nextToken.sourceRange
            try consumeToken()
            return VariableExpression(name: name, sourceRange: sourceRange)
        default:
            return nil
        }
    }
    
    private func parseExpression() throws -> Expression? {
        
        let simpleExpression = try parseSimpleExpression()
        if let simpleExpression = simpleExpression {
            
            if nextToken.payload == .dot {
                
                try consumeToken()  // dot
                guard if nextToken.payload == .leftParen else {
                    
                    throw CompilationError(sourceRange: range(startingAt: simpleExpression.sourceRange.start), errorMessage: "Invalid syntax: Expected '('")
                }
                try consumeToken()  // (
                let exp1 = try parseExpression()
                guard if nextToken.payload == .rightParen else {
                    
                    throw CompilationError(sourceRange: range(startingAt: simpleExpression.sourceRange.start), errorMessage: "Invalid syntax: Expected ')'")
                }
                try consumeToken()  // )
                if nextToken.payload == .lessMinus {
                    
                    try consumeToken()  // ->
                    let exp2 = try parseExpression()
                    return PutExpression(name: simpleExpression, addr: exp1, body: exp2, sourceRange: range(startingAt: simpleExpression.sourceRange.start))
                } else {
                    
                    return GetExpression(name: simpleExpression, addr: exp1, sourceRange: range(startingAt: simpleExpression.sourceRange.start))
                }
            } else {
                
                var args: [Expression] = []
                while let exp = try parseSimpleExpression() {
                    
                    args.append(exp)
                }
                return AppExpression(appName: simpleExpression, arguments: args, sourceRange: simpleExpression.sourceRange.start)
            }
        }
        
        // 無限ループを避けるために中置演算子はあとで処理する。
        switch nextToken.payload {
        case .not:
            let startLoc = nextToken.sourceRange.start
            try consumeToken()
            let rhs = try parseExpression()
            return SingleOperatorExpression(rhs: rhs, operator: .not)
        case .operator(name: "-"):
            let startLoc = nextToken.sourceRange.start
            try consumeToken()
            var floatFlag = false
            if nextToken.payload == .dot {
                
                try consumeToken()
                floatFlag = true
            }
            let exp = try parseExpression()
        }
    }
}
