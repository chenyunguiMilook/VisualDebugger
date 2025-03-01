//
//  Name.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/1.
//


public struct NameStyle {
    public enum Location: String {
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
}

extension NameStyle: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        // 检查是否包含 "@" 分隔符
        let components = value.split(separator: "@", maxSplits: 1, omittingEmptySubsequences: false)
        
        // 如果有分隔符并且有两部分
        if components.count == 2 {
            self.name = String(components[0])
            self.location = Location(rawValue: String(components[1])) ?? .right
        } else {
            // 如果没有分隔符，整个字符串作为 name，location 使用默认值 .right
            self.name = value
            self.location = .right
        }
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
            return .topCenter
        case .bottom:
            return .btmCenter
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
