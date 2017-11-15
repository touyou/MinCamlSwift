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
    
    
}
