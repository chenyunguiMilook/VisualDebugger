//
//  Circle.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/28.
//

import CoreGraphics

public struct Circle: ShapeRenderer {
    public var center: CGPoint
    public var radius: Double
    
    public var bounds: CGRect {
        CGRect(center: center, size: CGSize(width: radius * 2, height: radius * 2))
    }
    
    public init(center: CGPoint = .zero, radius: Double) {
        self.center = center
        self.radius = radius
    }
    
    public func getBezierPath() -> AppBezierPath {
        AppBezierPath(ovalIn: bounds)
    }
}

extension ShapeRenderer where Self == Circle {
    public static func circle(center: CGPoint = .zero, radius: Double) -> Circle {
        return Circle(center: center, radius: radius)
    }
}