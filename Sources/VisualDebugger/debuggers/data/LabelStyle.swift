//
//  LabelStyle.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/1.
//

public struct LabelStyle: Sendable {
    public var string: String
    public var filled: Bool
    
    public init(string: String, filled: Bool = false) {
        self.string = string
        self.filled = filled
    }
    
    public init(_ value: String) {
        let components = value.split(separator: "@", maxSplits: 1, omittingEmptySubsequences: false)
        if components.count == 2 {
            self.string = String(components[0])
            self.filled = String(components[1]) == "fill"
        } else {
            self.string = value
            self.filled = false
        }
    }
}

extension LabelStyle: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral value: String) {
        self.init(value)
    }
}
