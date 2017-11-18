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
    private func parseSimpleExpression() throws -> Expression {
        
        switch nextToken.payload {
        case .integer(let value):
            let sourceRange = nextToken.sourceRange
            try consumeToken()
            return IntegerLiteralExpression(value: value, sourceRange: sourceRange)
        case .float(let value):
            let sourceRange = nextToken.sourceRange
            try consumeToken()
            return FloatLiteralExpression(value: value, sourceRange: sourceRange)
        case .boolean(let value):
            let sourceRange = nextToken.sourceRange
            try consumeToken()
            return BooleanLiteralExpression(value: value, sourceRange: sourceRange)
        case .identifier(let name):
            let sourceRange = nextToken.sourceRange
            try consumeToken()
            return VariableExpression(name: name, sourceRange: sourceRange)
        case .leftParen:
            let sourceRange = nextToken.sourceRange
            try consumeToken()
            if nextToken.payload == .rightParen {
                
                return Expression(sourceRange: sourceRange)     // Unit
            } else {
                
                // TODO: normal expression
            }
        }
    }
}
