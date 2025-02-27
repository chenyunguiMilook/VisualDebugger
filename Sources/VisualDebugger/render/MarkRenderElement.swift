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
        // 完全应用变换（旋转+平移）
        return MarkRenderElement(path: lhs.path, style: lhs.style, position: lhs.position * rhs, rotatable: lhs.rotatable)
    } else {
        // 分解变换，只应用平移，忽略旋转
        // 提取平移部分
        let tx = rhs.tx
        let ty = rhs.ty
        let translationOnly = Matrix2D(translationX: tx, y: ty)
        
        return MarkRenderElement(path: lhs.path, style: lhs.style, position: lhs.position * translationOnly, rotatable: lhs.rotatable)
    }
}
