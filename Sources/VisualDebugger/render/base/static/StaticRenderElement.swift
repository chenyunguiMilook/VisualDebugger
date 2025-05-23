//
//  MarkRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import CoreGraphics
import VisualUtils

public struct StaticRenderElement<Content: StaticRendable>: Transformable, DebugRenderable {
    
    public let content: Content
    public let position: CGPoint // this is raw position, transform will no affect this
    public let transform: Matrix2D
    
    public init(content: Content, position: CGPoint, transform: Matrix2D = .identity) {
        self.content = content
        self.position = position
        self.transform = transform
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
    public init(source: ShapeRenderer, style: ShapeRenderStyle, position: CGPoint, transform: Matrix2D = .identity) {
        self.content = ShapeElement(renderer: source, style: style)
        self.position = position
        self.transform = transform
    }
}

extension StaticRenderElement where Content == TextElement {
    public init(source: TextSource, style: TextRenderStyle, position: CGPoint, transform: Matrix2D = .identity) {
        self.content = TextElement(source: source, style: style)
        self.position = position
        self.transform = transform
    }
}

public func *<T>(lhs: StaticRenderElement<T>, rhs: Matrix2D) -> StaticRenderElement<T> {
    return StaticRenderElement(
        content: lhs.content,
        position: lhs.position,
        transform: lhs.transform * rhs
    )
}

public typealias StaticShapeElement = StaticRenderElement<ShapeElement>
public typealias StaticTextElement = StaticRenderElement<TextElement>
