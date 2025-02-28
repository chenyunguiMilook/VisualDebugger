//
//  NumberRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import CoreGraphics
import Foundation

public struct NumberRenderElement: ContextRenderable {
    
    public let value: Double
    public let formatter: NumberFormatter
    public let style: TextRenderStyle
    public let position: CGPoint
    
    public var text: String? {
        self.formatter.string(from: NSNumber(value: value))
    }
    
    public var bounds: CGRect? {
        guard let text else { return nil }
        let size = self.style.getTextSize(text: text)
        return CGRect(anchor: style.anchor, center: position, size: size)
    }
    
    public init(value: Double, formatter: NumberFormatter, style: TextRenderStyle, position: CGPoint) {
        self.value = value
        self.formatter = formatter
        self.style = style
        self.position = position
    }
    
    public init(value: Double, precision: Int, style: TextRenderStyle, position: CGPoint) {
        self.value = value
        self.formatter = NumberFormatter()
        self.formatter.numberStyle = .decimal
        self.formatter.maximumFractionDigits = precision
        self.formatter.roundingMode = .halfUp
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
        guard let text else { return }
        context.render(
            text: text,
            transform: Matrix2D(translation: position),
            style: style,
            scale: scale,
            contextHeight: contextHeight
        )
    }
}

public func *(lhs: NumberRenderElement, rhs: Matrix2D) -> NumberRenderElement {
    NumberRenderElement(value: lhs.value, formatter: lhs.formatter, style: lhs.style, position: lhs.position * rhs)
}
