//
//  TextElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics

public final class TextElement: StaticRendable {
    
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
        with transform: Matrix2D,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    ) {
        let t = Matrix2D(translationX: transform.tx, y: transform.ty)
        context.render(
            text: source.string,
            transform: t,
            style: style,
            scale: scale,
            contextHeight: contextHeight
        )
    }
    
    public func clone() -> TextElement {
        TextElement(source: source, style: style)
    }
}

extension TextElement {
    public static func label(_ label: String, at location: TextLocation = .right) -> TextElement {
        var style = TextRenderStyle.nameLabel
            style.setTextLocation(location)
        return TextElement(source: .string(label), style: style)
    }
}
