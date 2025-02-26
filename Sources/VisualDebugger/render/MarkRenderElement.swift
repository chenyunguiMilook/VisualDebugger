//
//  MarkRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


import CoreGraphics

public struct MarkRenderElement: ContextRenderable {
    
    public let path: AppBezierPath
    public let style: ShapeRenderStyle
    public let position: CGPoint
    
    public init(path: AppBezierPath, style: ShapeRenderStyle, position: CGPoint) {
        self.path = path
        self.style = style
        self.position = position
    }
    
    public func render(in context: CGContext, contentScaleFactor: CGFloat, contextHeight: Int?) {
        guard let path = path * Matrix2D(translation: position) else { return }
        context.render(path: path.cgPath, style: style)
    }
}

public func *(lhs: MarkRenderElement, rhs: Matrix2D) -> MarkRenderElement {
    MarkRenderElement(path: lhs.path, style: lhs.style, position: lhs.position * rhs)
}
