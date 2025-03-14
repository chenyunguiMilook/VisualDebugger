//
//  TextSource.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import Foundation

public enum TextSource {
    
    case string(String)
    case number(Double, formatter: NumberFormatter)
    case index(Int)
    
    // TODO: add date etc...
    
    public var string: String {
        switch self {
        case .string(let string):
            return string
        case .number(let value, formatter: let formatter):
            return formatter.string(from: NSNumber(value: value)) ?? "0"
        case .index(let value):
            return "\(value)"
        }
    }
}

extension TextSource {
    public static func number(value: Double, precision: Int) -> TextSource {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = precision
        formatter.roundingMode = .halfUp
        return .number(value, formatter: formatter)
    }
}

extension TextSource: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}
