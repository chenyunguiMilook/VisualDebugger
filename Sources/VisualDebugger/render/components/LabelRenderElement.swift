//
//  LabelRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/1.
//

import CoreGraphics

public struct LabelRenderElement: ContextRenderable {
    
    public let label: LabelStyle
    public let style: TextRenderStyle
    public let position: CGPoint
    
    public init(label: LabelStyle, style: TextRenderStyle, position: CGPoint) {
        var s = style
        s.bgStyle = .capsule(color: s.bgStyle?.color ?? .red, filled: label.filled)
        self.label = label
        self.style = s
        self.position = position
    }
    
    public func applying(transform: Matrix2D) -> LabelRenderElement {
        self * transform
    }

    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        context.render(
            text: label.string,
            transform: Matrix2D(translation: position),
            style: style,
            scale: scale,
            contextHeight: contextHeight
        )
    }
}

public func *(lhs: LabelRenderElement, rhs: Matrix2D) -> LabelRenderElement {
    LabelRenderElement(label: lhs.label, style: lhs.style, position: lhs.position * rhs)
}
