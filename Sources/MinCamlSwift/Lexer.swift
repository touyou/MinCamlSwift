//
//  Lexer.swift
//  MinCamlSwiftPackageDescription
//
//  Created by 藤井陽介 on 2017/11/07.
//

import Foundation

// MARK: - UnicodeScalar extensions

fileprivate extension UnicodeScalar {
    
    var isWhitespace: Bool {
        
        return self == " " || self == "\t" || self == "\n" || self == "\r"
    }
    
    var isAlpha: Bool {
        
        let alphaChars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".unicodeScalars)
        return alphaChars.contains(self)
    }
    
    var isNumeric: Bool {
        
        let numChars = Set("0123456789".unicodeScalars)
        return numChars.contains(self)
    }
    
    var isAlnum: Bool {
        
        return isAlpha || isNumeric
    }
    
    /// Valid identifier characters are alphanumeric or '_' or '.' (for i.e. Array.create, and more)
    var isIdentifier: Bool {
        
        return isAlnum || self == "_" || self == "."
    }
    
    /// If the character represents a character that can occur in operators
    /// Currently includes '+', '-', '*', '/', '='
    /// and Dot operator
    var isOperator: Bool {
        
        let operatorChars = Set("+-*/=<>".unicodeScalars)
        return operatorChars.contains(self)
    }
}

// MARK: - Lexer

public class Lexer {
    /// The scanner is responsible to return characters in the source code one by one and maintain
    /// the source location of these characters
    private let scanner: Scanner
    
    /// Create a new lexer to lex the given source code
    ///
    /// - Parameter sourceCode: The source code to lex
    public init(sourceCode: String) {
        
        self.scanner = Scanner(sourceCode: sourceCode)
    }
    
    /// Lex the next token in the source code and return it
    ///
    /// - Returns: The next token in the source code
    /// - Throws: A CompilationError if the next token could not be lexed
    public func nextToken() throws -> Token {
        
        while let char = scanner.currentChar, char.isWhitespace {
            
            scanner.consumeChar()
        }
        
        let directCharacterMapping: [UnicodeScalar: TokenKind] = [
            ")": .rightParen,
            ",": .comma,
            ".": .dot,
            ";": .semicolon,
        ]
        
        switch scanner.currentChar {
        case let .some(char) where char.isAlnum:
            return lexIdentifier()
        case let .some(char) where char.isNumeric:
            return lexNumberLiteral()
        case let .some(char) where char.isOperator:
            return try lexOperator()
        case let .some(char) where char == "(":
            return lexComment()
        case let .some(char) where directCharacterMapping.keys.contains(char):
            let startLoc = scanner.sourceLoc
            scanner.consumeChar()
            return Token(directCharacterMapping[char], sourceRange: range(startingAt: startLoc))
        case nil:
            return Token(.endOfFile, sourceRange: range(startingAt: scanner.sourceLoc))
        default:
            defer {
                
                scanner.consumeChar()
            }
            throw CompilationError(location: scanner.sourceLoc,
                                   errorMessage: "Invalid character: '\(scanner.currentChar!)'")
        }
    }
    
    /// Helper method to create a source range starting at the given location and ending at the
    /// next character to be parsed
    ///
    /// - Parameter startingAt: The location where the source range shall start
    /// - Returns: A source range from the given location to the current scanner position
    private func range(startingAt: SourceLoc) -> SourceRange {
        
        return SourceRange(start: startingAt, end: scanner.sourceLoc)
    }
    
    /// Keep consuming characters while they satisfy the given condition and return the string made
    /// up from these characters
    ///
    /// - Parameter condition: Cather characters that satisfy this condition
    /// - Returns: The string made up from the characters that satisfy the given condition
    private func gatherWhile(_ condition: (UnicodeScalar) -> Bool) -> String {
        
        var buildupString = ""
        while let char = scanner.currentChar, condition(char) {
            
            buildupString.append(String(char))
            scanner.consumeChar()
        }
        return buildupString
    }
    
    private func lexIdentifier() -> Token {
        
        let startLoc = scanner.sourceLoc
        let name = gatherWhile({ $0.isIdentifier })
        let tokenKind: TokenKind
        switch name {
        case "if":
            tokenKind = .if
        case "then":
            tokenKind = .then
        case "else":
            tokenKind = .else
        case "let":
            tokenKind = .let
        case "in":
            tokenKind = .in
        case "rec":
            tokenKind = .rec
        case "fun":
            tokenKind = .fun
        case "create_array", "Array.create", "Array.make":
            tokenKind = .createArray
        case "input":
            tokenKind = .input
        case "output":
            tokenKind = .output
        case "lxor", "lor", "land", "lsl", "lsr:
            tokenKind = .operator(name: name)
        case "not":
            tokenKind = .not
        case "true":
            tokenKind = .boolean(value: true)
        case "false":
            tokenKind = .boolean(value: false)
        default:
            tokenKind = .identifier(name: name)
        }
        
        return Token(tokenKind, sourceRange: range(startingAt: startLoc))
    }
    
    // TODO: If we use pointer, this can be written simpler.
    private func lexNumberLiteral() -> Token {
        
        let startLoc = scanner.sourceLoc
        var buildupString = gatherWhile({ $0.isNumeric })
        
        if let char = scanner.currentChar, char == "." {
            
            // MARK: If contain '.'
            buildupString.append(char)
            scanner.consumeChar()
            buildupString.append(gatherWhile({ $0.isNumeric }))
            if let char = scanner.currentChar, char == "e" || char == "E" {
                
                buildupString.append(char)
                scanner.consumeChar()
                if let char = scanner.currentChar, char == "+" || char == "-" {
                    
                    buildupString.append(char)
                    scanner.consumeChar()
                }
                buildupString.append(gatherWhile({ $0.isNumeric }))
            }
            
            return Token(.float(value: Double(buildupString)!), sourceRange: range(startingAt: startLoc))
        } else if let char = scanner.currentChar, char == "e" || char == "E" {
            
            // MARK: If contain 'e' or 'E'
            buildupString.append(char)
            scanner.consumeChar()
            if let char = scanner.currentChar, char == "+" || char == "-" {
                
                buildupString.append(char)
                scanner.consumeChar()
            }
            buildupString.append(gatherWhile({ $0.isNumeric }))
            
            return Token(.float(value: Double(buildupString)!), sourceRange: range(startingAt: startLoc))
        }
        
        return Token(.integer(value: buildupString)!, sourceRange: range(startingAt: startLoc))
    }
    
    private func lexOperator() throws -> Token {
        
        let startLoc = scanner.sourceLoc
        let name = gatherWhile({ $0.isOperator })
        let tokenKind: TokenKind
        switch name {
        case "->":
            tokenKind = .minusGreater
        case "<-":
            tokenKind = .lessMinus
        case "+", "-", "*", "/":
            let opeName = name
            if let char = scanner.currentChar, char == "." {
                
                opeName.append(char)
                scanner.consumeChar()
            }
            tokenKind = .operator(name: opeName)
        case "=", "<>", "<=", ">=",
             "<", ">":
            tokenKind = .operator(name: name)
        default:
            throw CompilationError(location: startLoc,
                                   errorMessage: "Invalid operator: '\(name)'")
        }
        return Token(tokenKind, sourceRange: range(startingAt: startLoc))
    }
    
    private func lexComment() -> Token {
        
        let startLoc = scanner.sourceLoc
        scanner.consumeChar()
        if let char = scanner.currentChar, char == "*" {
            
            // This is comment
            var commentNest = 1
            while let char = scanner.currentChar {
                
                switch char {
                case "*":
                    scanner.consumeChar()
                    if let char = scanner.currentChar, char == ")" {
                        
                        scanner.consumeChar()
                        commentNest -= 1
                        if commentNest == 0 {
                            
                            break
                        }
                    }
                case "(":
                    scanner.consumeChar()
                    if let char = scanner.currentChar, char == "*" {
                        
                        scanner.consumeChar()
                        commentNest += 1
                    }
                default:
                    scanner.consumeChar()
                }
            }
            
            if commentNest != 0 && scanner.currentChar == nil {
                
                print("warning: unterminated comment.")
            }
            return Token(.comment, sourceRange: range(startingAt: startLoc))
        }
        
        // Only left paranthesis
        return Token(.leftParen, sourceRange: range(startingAt: startLoc))
    }
}
