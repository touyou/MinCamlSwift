//
//  SourceFile.swift
//  MinCamlSwiftPackageDescription
//
//  Created by 藤井陽介 on 2017/11/07.
//

import Foundation

/// Represents the source code that was contained in a `.ml` file
public struct SourceFile: _ExpressibleByFileReferenceLiteral, CustomStringConvertible {
    public let sourceCode: String
    
    public init(fileReferenceLiteralResourceName path: String) {
        let url = Bundle.main.url(forResource: path, withExtension: nil)!
        sourceCode = try! String(contentsOf: url)
    }
    
    /// Create a `SourceFile` with manually obtained source code
    ///
    /// - Parameter sourceCode: The source code of the file
    public init(fromSourceCode sourceCode: String) {
        self.sourceCode = sourceCode
    }
    
    public var description: String {
        return sourceCode
    }
}
