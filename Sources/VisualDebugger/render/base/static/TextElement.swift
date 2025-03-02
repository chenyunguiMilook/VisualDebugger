//
//  TextElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics

public class TextElement: StaticRendable {
    
    public var source: TextSource
    public var style: TextRenderStyle
    
    public init(source: TextSource, style: TextRenderStyle) {
        self.source = source
        self.style = style
    }
    
    public var contentBounds: CGRect {
        let size = self.style.getTextSize(text: source.string)
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
            text: source.string,
            transform: r * t,
            style: style,
            scale: scale,
            contextHeight: contextHeight
        )
    }
}
