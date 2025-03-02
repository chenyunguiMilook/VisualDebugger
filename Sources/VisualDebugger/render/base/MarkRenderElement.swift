//
//  MarkRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import CoreGraphics

public struct MarkRenderElement<Content: StaticRendable>: ContextRenderable {
    
    public let content: Content
    public let position: CGPoint
    public let angle: Double
    public let rotatable: Bool  // 决定是否受旋转变换影响
    
    public init(content: Content, position: CGPoint, angle: Double = 0, rotatable: Bool = false) {
        self.content = content
        self.position = position
        self.angle = angle
        self.rotatable = rotatable
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        self.content.render(
            to: position,
            angle: angle,
            in: context,
            scale: scale,
            contextHeight: contextHeight
        )
    }
}

extension MarkRenderElement where Content == ShapeElement {
    public init(path: AppBezierPath, style: ShapeRenderStyle, position: CGPoint, angle: Double = 0, rotatable: Bool = false) {
        self.content = ShapeElement(path: path, style: style)
        self.position = position
        self.angle = angle
        self.rotatable = rotatable
    }
}

public func *<T>(lhs: MarkRenderElement<T>, rhs: Matrix2D) -> MarkRenderElement<T> {
    var rotation = lhs.angle
    if lhs.rotatable {
        rotation += rhs.decomposed().rotation
    }
    return MarkRenderElement(
        content: lhs.content,
        position: lhs.position * rhs,
        angle: rotation,
        rotatable: lhs.rotatable
    )
}
