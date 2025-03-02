//
//  TextElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics

public struct TextElement: StaticRendable {
    
    public let text: String
    public let style: TextRenderStyle
    
    public init(text: String, style: TextRenderStyle) {
        self.text = text
        self.style = style
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
