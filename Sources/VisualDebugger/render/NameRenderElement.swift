//
//  NameRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/1.
//

import CoreGraphics

public struct NameRenderElement: ContextRenderable {
    
    public let name: NameStyle
    public let style: TextRenderStyle
    public let position: CGPoint
    
    public init(name: NameStyle, style: TextRenderStyle, position: CGPoint) {
        var s = style
        s.anchor = name.location.anchor
        self.name = name
        self.style = s
        self.position = position
    }
    
    public func applying(transform: Matrix2D) -> NameRenderElement {
        self * transform
    }

    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        context.render(
            text: name.name,
            transform: Matrix2D(translation: position),
            style: style,
            scale: scale,
            contextHeight: contextHeight
        )
    }
}

public func *(lhs: NameRenderElement, rhs: Matrix2D) -> NameRenderElement {
    NameRenderElement(name: lhs.name, style: lhs.style, position: lhs.position * rhs)
}
