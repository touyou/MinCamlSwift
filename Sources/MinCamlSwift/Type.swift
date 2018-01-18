//
//  Type.swift
//  MinCamlSwiftPackageDescription
//
//  Created by 藤井陽介 on 2017/11/13.
//

import Foundation

/// Type enumeration
public enum Type: CustomDebugStringConvertible {
    case unit
    case bool
    case int
    case float
    case fun(Type, [Type])
    case tuple([Type])
    case array(Type)
    case `var`(Type?)
    
    public var debugDescription: String {
        
        switch self {
        case .unit:
            return "u"
        case .bool:
            return "b"
        case .int:
            return "i"
        case .float:
            return "d"
        case .fun(_, _):
            return "f"
        case .tuple(_):
            return "t"
        case .array(_):
            return "a"
        case .var(_):
            assert(false)
        }
    }
    
    public func genType() -> self {
        
        return .var(nil)
    }
}
