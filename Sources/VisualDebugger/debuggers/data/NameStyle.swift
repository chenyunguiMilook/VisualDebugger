//
//  Name.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/1.
//


public struct NameStyle: Sendable {
    public enum Location: String, Sendable {
        case center
        case left, right, top, bottom
        case topLeft, topRight, bottomLeft, bottomRight
    }
    public var name: String
    public var location: Location
    
    public init(name: String, location: Location = .right) {
        self.name = name
        self.location = location
    }
    
    public init(_ value: String) {
        let components = value.split(separator: "@", maxSplits: 1, omittingEmptySubsequences: false)
        if components.count == 2 {
            self.name = String(components[0])
            self.location = Location(rawValue: String(components[1])) ?? .right
        } else {
            self.name = value
            self.location = .right
        }
    }

}

extension NameStyle: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension NameStyle.Location {
    var anchor: Anchor {
        switch self {
        case .center:
            return .midCenter
        case .left:
            return .midRight
        case .right:
            return .midLeft
        case .top:
            return .btmCenter
        case .bottom:
            return .topCenter
        case .topLeft:
            return .btmRight
        case .topRight:
            return .btmLeft
        case .bottomLeft:
            return .topRight
        case .bottomRight:
            return .topLeft
        }
    }
}
