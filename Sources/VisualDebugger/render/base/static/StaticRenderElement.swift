//
//  MarkRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import CoreGraphics

public struct StaticRenderElement<Content: StaticRendable>: Debuggable {
    
    // TODO: 给它加一个transform属性， 这样原始位置仍然可以被保存
    
    public let content: Content
    public let position: CGPoint
    public let angle: Double
    public let rotatable: Bool  // 决定是否受旋转变换影响
    
    public init(content: Content, position: CGPoint, angle: Double = 0, rotatable: Bool = false) {
        self.content = content
        self.position = position
        self.angle = angle
        self.rotatable = rotatable
    }
    
    public var debugBounds: CGRect? {
        let o = CGRect(center: position, size: .unit)
        let b = self.content.contentBounds
        return [o, b].bounds
    }
    
    public func applying(transform: Matrix2D) -> StaticRenderElement<Content> {
        self * transform
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        self.content.render(
            to: position,
            angle: angle,
            in: context,
            scale: scale,
            contextHeight: contextHeight
        )
    }
}

extension StaticRenderElement where Content == ShapeElement {
    public init(source: ShapeSource, style: ShapeRenderStyle, position: CGPoint, angle: Double = 0, rotatable: Bool = false) {
        self.content = ShapeElement(source: source, style: style)
        self.position = position
        self.angle = angle
        self.rotatable = rotatable
    }
}

extension StaticRenderElement where Content == TextElement {
    public init(source: TextSource, style: TextRenderStyle, position: CGPoint, angle: Double = 0, rotatable: Bool = false) {
        self.content = TextElement(source: source, style: style)
        self.position = position
        self.angle = angle
        self.rotatable = rotatable
    }
}

public func *<T>(lhs: StaticRenderElement<T>, rhs: Matrix2D) -> StaticRenderElement<T> {
    var rotation = lhs.angle
    if lhs.rotatable {
        rotation += rhs.decomposed().rotation
    }
    return StaticRenderElement(
        content: lhs.content,
        position: lhs.position * rhs,
        angle: rotation,
        rotatable: lhs.rotatable
    )
}

public typealias StaticShapeElement = StaticRenderElement<ShapeElement>
public typealias StaticTextElement = StaticRenderElement<TextElement>
