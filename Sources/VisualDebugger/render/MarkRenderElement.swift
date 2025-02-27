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
    public let rotatable: Bool  // 决定是否受旋转变换影响
    
    public init(path: AppBezierPath, style: ShapeRenderStyle, position: CGPoint, rotatable: Bool = false) {
        self.path = path
        self.style = style
        self.position = position
        self.rotatable = rotatable
    }
    
    public func render(in context: CGContext, contentScaleFactor: CGFloat, contextHeight: Int?) {
        guard let path = path * Matrix2D(translation: position) else { return }
        context.render(path: path.cgPath, style: style)
    }
}

public func *(lhs: MarkRenderElement, rhs: Matrix2D) -> MarkRenderElement {
    if lhs.rotatable {
        // 如果是可旋转的，应该旋转路径，而位置正常变换
        let rotation = Matrix2D(rotationAngle: rhs.decomposed().rotation)
        let rotatedPath = (lhs.path * rotation) ?? AppBezierPath()
        return MarkRenderElement(path: rotatedPath, style: lhs.style, position: lhs.position * rhs, rotatable: lhs.rotatable)
    } else {
        // 不可旋转的情况下，路径保持不变，位置正常变换
        return MarkRenderElement(path: lhs.path, style: lhs.style, position: lhs.position * rhs, rotatable: lhs.rotatable)
    }
}
