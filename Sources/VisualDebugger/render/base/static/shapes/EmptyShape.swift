//
//  EmptyShape.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/22.
//

import CoreGraphics
import VisualUtils

public struct EmptyShape: ShapeRenderer {
    public var center: CGPoint
    public var radius: Double = 0
    
    public var bounds: CGRect {
        CGRect(center: center, size: .zero)
    }
    
    public init(center: CGPoint = .zero) {
        self.center = center
    }
    
    public func getBezierPath() -> AppBezierPath {
        AppBezierPath()
    }
}

extension ShapeRenderer where Self == EmptyShape {
    public static func empty() -> EmptyShape {
        return EmptyShape()
    }
}
