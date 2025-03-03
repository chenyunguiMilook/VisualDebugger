//
//  StaticShape.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics

public enum ShapeType {
    public typealias ShapeBuilder = (_ rect: CGRect) -> AppBezierPath
    
    public enum ArrowStyle {
        case full
        case top
        case bottom
    }
    
    case circle
    case triangle
    case rect
    case range
    case arrow(ArrowStyle)
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
        case .range:
            let path = AppBezierPath()
            path.move(to: bounds.topRight)
            path.addLine(to: bounds.bottomRight)
            path.move(to: bounds.topLeft)
            path.addLine(to: bounds.middleRight)
            path.addLine(to: bounds.bottomLeft)
            return path
        case .arrow(let arrowStyle):
            let p1: CGPoint
            let p2: CGPoint
            switch arrowStyle {
            case .full:
                p1 = bounds.topLeft
                p2 = bounds.bottomLeft
            case .top:
                p1 = bounds.topLeft
                p2 = bounds.middleLeft
            case .bottom:
                p1 = bounds.middleLeft
                p2 = bounds.bottomLeft
            }
            let path = AppBezierPath()
            path.move(to: .zero)
            path.addLine(to: p1)
            path.addLine(to: p2)
            path.close()
            return path
        }
    }
}
