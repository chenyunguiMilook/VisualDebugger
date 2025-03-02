//
//  StaticShape.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics

public enum ShapeType {
    public typealias ShapeBuilder = (_ size: CGSize, _ anchor: Anchor) -> AppBezierPath
    
    public enum ArrowStyle {
        case full
        case top
        case bottom
    }
    
    case circle
    case triangle
    case rect
    case arrow(ArrowStyle)
    case custom(ShapeBuilder)
}

extension ShapeType {
    
    public func createPath(size: CGSize, anchor: Anchor) -> AppBezierPath {
        let bounds = CGRect(anchor: anchor, center: .zero, size: size)
        
        
        fatalError("need implementation")
    }
}
