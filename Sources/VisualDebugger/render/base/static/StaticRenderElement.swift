//
//  MarkRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import CoreGraphics

public struct StaticRenderElement<Content: StaticRendable>: Transformable, Debuggable {
    
    public let content: Content
    public let position: CGPoint // this is raw position, transform will no affect this
    public let transform: Matrix2D
    public let rotatable: Bool  // 决定是否受旋转变换影响
    
    public init(content: Content, position: CGPoint, transform: Matrix2D = .identity, rotatable: Bool = false) {
        self.content = content
        self.position = position
        self.transform = transform
        self.rotatable = rotatable
    }
    
    public var debugBounds: CGRect? {
        let pos = position * transform
        return self.content.contentBounds.offseted(pos)
    }
    
    public func applying(transform: Matrix2D) -> StaticRenderElement<Content> {
        self * transform
    }
    
    public func render(with matrix: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        self.content.render(
            with: Matrix2D(translation: position) * transform * matrix,
            in: context,
            scale: scale,
            contextHeight: contextHeight
        )
    }
}

extension StaticRenderElement where Content == ShapeElement {
    public init(source: ShapeSource, style: ShapeRenderStyle, position: CGPoint, transform: Matrix2D = .identity, rotatable: Bool = false) {
        self.content = ShapeElement(source: source, style: style)
        self.position = position
        self.transform = transform
        self.rotatable = rotatable
    }
}

extension StaticRenderElement where Content == TextElement {
    public init(source: TextSource, style: TextRenderStyle, position: CGPoint, transform: Matrix2D = .identity, rotatable: Bool = false) {
        self.content = TextElement(source: source, style: style)
        self.position = position
        self.transform = transform
        self.rotatable = rotatable
    }
}

public func *<T>(lhs: StaticRenderElement<T>, rhs: Matrix2D) -> StaticRenderElement<T> {
    return StaticRenderElement(
        content: lhs.content,
        position: lhs.position,
        transform: lhs.transform * rhs,
        rotatable: lhs.rotatable
    )
}

public typealias StaticShapeElement = StaticRenderElement<ShapeElement>
public typealias StaticTextElement = StaticRenderElement<TextElement>
