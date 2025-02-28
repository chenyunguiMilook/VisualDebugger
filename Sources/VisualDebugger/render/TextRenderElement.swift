//
//  TextRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


import CoreGraphics

public struct TextRenderElement: ContextRenderable {
    
    public let text: String
    public let style: TextRenderStyle
    public let position: CGPoint
    
    public init(text: String, style: TextRenderStyle, position: CGPoint) {
        self.text = text
        self.style = style
        self.position = position
    }
    
    public func render(in context: CGContext) {
        self.render(
            in: context,
            scale: 1,
            contextHeight: nil
        )
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        context.render(
            text: self.text,
            transform: Matrix2D(translation: position),
            style: style,
            scale: scale,
            contextHeight: contextHeight
        )
    }
}

public func *(lhs: TextRenderElement, rhs: Matrix2D) -> TextRenderElement {
    TextRenderElement(text: lhs.text, style: lhs.style, position: lhs.position * rhs)
}
