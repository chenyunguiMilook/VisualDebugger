//
//  ShapeRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import Foundation
import CoreGraphics

public struct ShapeRenderElement: ContextRenderable {
    
    public let path: AppBezierPath
    public let style: ShapeRenderStyle
    
    public init(path: AppBezierPath, style: ShapeRenderStyle) {
        self.path = path
        self.style = style
    }
    
    public func render(in context: CGContext, contentScaleFactor: CGFloat, contextHeight: Int?) {
        context.render(path: path.cgPath, style: style)
    }
}

public func *(lhs: ShapeRenderElement, rhs: Matrix2D) -> ShapeRenderElement {
    let path = (lhs.path * rhs) ?? AppBezierPath()
    return ShapeRenderElement(path: path, style: lhs.style)
}
