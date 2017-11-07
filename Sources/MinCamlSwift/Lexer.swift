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
    
    /// Valid identifier characters are alphanumeric or '_'
    var isIdentifier: Bool {
        
        return isAlnum || self == "_"
    }
    
    /// If the character represents a character that can occur in operators
    /// Currently includes '+', '-', '*', '/', '='
    var isOperator: Bool {
        
        let operatorChars = Set("+-*/=<>".unicodeScalars)
        return operatorChars.contains(self)
    }
}


