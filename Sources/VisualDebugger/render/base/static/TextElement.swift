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
    public var rotatable: Bool
    
    public init(source: TextSource, style: TextRenderStyle, rotatable: Bool = false) {
        self.source = source
        self.style = style
        self.rotatable = rotatable
    }
    
    public init(text: String, style: TextRenderStyle, rotatable: Bool = false) {
        self.source = .string(text)
        self.style = style
        self.rotatable = rotatable
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
        var t = Matrix2D(translationX: transform.tx, y: transform.ty)
        if rotatable {
            var angle = transform.decompose().rotation
            angle = convertToReadableAngle(angle)
            t = Matrix2D(rotationAngle: angle) * t
        }
        context.render(
            text: source.string,
            transform: t,
            style: style,
            scale: scale,
            contextHeight: contextHeight
        )
    }
    
    public func clone() -> TextElement {
        TextElement(source: source, style: style, rotatable: rotatable)
    }
    
    /**
     将任意弧度转换为适合阅读的弧度（-π/2到π/2之间）
     
     根据阅读习惯，我们通常从左往右阅读文字，即弧度在 -π/2到π/2之间。
     当文字弧度超出这个范围时，需要旋转π弧度使其可读。
     
     - Parameter angle: 原始弧度
     - Returns: 转换后的适合阅读的弧度
     */
    func convertToReadableAngle(_ angle: Double) -> Double {
        // 首先将弧度标准化到 [-π, π] 范围内
        let π = Double.pi
        var normalizedAngle = angle.truncatingRemainder(dividingBy: 2 * π)
        
        if normalizedAngle > π {
            normalizedAngle -= 2 * π
        } else if normalizedAngle < -π {
            normalizedAngle += 2 * π
        }
        
        // 检查弧度是否在 [-π/2, π/2] 范围内
        // 如果不是，则旋转π弧度
        if normalizedAngle > π/2 && normalizedAngle <= π {
            normalizedAngle -= π
        } else if normalizedAngle < -π/2 && normalizedAngle >= -π {
            normalizedAngle += π
        }
        return normalizedAngle
    }
}

extension TextElement {
    public static func label(_ label: String, at location: TextLocation = .right) -> TextElement {
        var style = TextRenderStyle.nameLabel
            style.setTextLocation(location)
        return TextElement(source: .string(label), style: style)
    }
}
