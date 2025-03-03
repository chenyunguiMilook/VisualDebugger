//
//  StaticShape.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics

public enum ShapeType {
    public typealias ShapeBuilder = (_ rect: CGRect) -> AppBezierPath
    
    case circle
    case triangle
    case rect
}

extension ShapeType {
    
    public func createPath(size: CGSize, anchor: Anchor) -> AppBezierPath {
        let bounds = CGRect(anchor: anchor, center: .zero, size: size)
        switch self {
        case .circle:
            return AppBezierPath(ovalIn: bounds)
        case .triangle:
            let r = min(bounds.width, bounds.height) / 2.0
            return Polygon(center: bounds.center, radius: r, edgeCount: 3).getBezierPath()
        case .rect:
            return AppBezierPath(rect: bounds)
        }
    }
}
