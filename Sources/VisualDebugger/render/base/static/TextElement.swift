//
//  TextElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics

public class TextElement: StaticRendable {
    
    public var text: String
    public var style: TextRenderStyle
    
    public init(text: String, style: TextRenderStyle) {
        self.text = text
        self.style = style
    }
    
    public var contentBounds: CGRect {
        let size = self.style.getTextSize(text: self.text)
        return CGRect(anchor: style.anchor, center: .zero, size: size)
    }
    
    public func render(
        to location: CGPoint,
        angle: Double,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    ) {
        let r = Matrix2D(rotationAngle: angle)
        let t = Matrix2D(translation: location)
        context.render(
            text: self.text,
            transform: r * t,
            style: style,
            scale: scale,
            contextHeight: contextHeight
        )
    }
}
