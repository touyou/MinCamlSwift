//
//  Id.swift
//  MinCamlSwiftPackageDescription
//
//  Created by 藤井陽介 on 2017/11/13.
//

import Foundation

/// Identifier class
public class IdentifierManager {
    
    static let shared = Identifier()
    
    var counter: Int
    
    init() {
        
        self.counter = 0
    }
    
    public func genIdentifier(str: String) -> String {
        
        counter += 1
        return "\(str).\(counter)"
    }
    
    public func genTemporaryVariable(type: Type) {
        
        counter += 1
        return "T\(type.debugDescription)\(counter)"
    }
}
