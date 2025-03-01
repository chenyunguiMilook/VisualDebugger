//
//  VertexStyle.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/28.
//

import CoreGraphics


public enum VertexShape: Sendable {
    case rect, filledRect
    case circle, filledCircle
    case triangle, filledTriangle
    
    var fill: VertexShape {
        switch self {
        case .rect: .filledRect
        case .circle: .filledCircle
        case .triangle: .filledTriangle
        default: self
        }
    }
    
    var isFilled: Bool {
        switch self {
        case .filledRect, .filledCircle, .filledTriangle: true
        default: false
        }
    }
}

extension VertexShape {
    public func getPath(radius: Double) -> AppBezierPath {
        let rect = CGRect(center: .zero, size: .init(width: radius * 2, height: radius * 2))
        switch self {
        case .rect, .filledRect:
            return AppBezierPath(rect: rect)
        case .circle, .filledCircle:
            return AppBezierPath(ovalIn: rect)
        case .triangle, .filledTriangle:
            return Polygon(center: .zero, radius: radius, edgeCount: 3).getBezierPath()
        }
    }
}

public enum VertexRepresentation: Sendable {
    case shape(VertexShape)
    case index
    case label(LabelStyle)
}

public struct VertexStyle : Sendable {
    public let style: VertexRepresentation
    public let name: NameStyle?
    
    public init(style: VertexRepresentation = .shape(.circle), name: NameStyle? = nil) {
        self.style = style
        self.name = name
    }
}

extension VertexStyle {
    public static let `default` = VertexStyle()
    
    public static func shape(_ shape: VertexShape, name: NameStyle? = nil) -> VertexStyle {
        VertexStyle(style: .shape(shape), name: name)
    }
    public static func label(_ label: LabelStyle, name: NameStyle? = nil) -> VertexStyle {
        VertexStyle(style: .label(label), name: name)
    }
    public static func index(name: NameStyle? = nil) -> VertexStyle{
        VertexStyle(style: .index, name: name)
    }
}
