//
//  SegmentElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics

public final class SegmentRenderElement<T: SegmentRenderer>: ContextRenderable {
    
    public let start: CGPoint
    public let end: CGPoint
    public let transform: Matrix2D
    public var startElement: StaticRendable?
    public var endElement: StaticRendable?
    public var renderer: T
    
    public init(start: CGPoint, end: CGPoint, transform: Matrix2D = .identity, renderer: T) {
        self.start = start
        self.end = end
        self.transform = transform
        self.renderer = renderer
    }
    
    public func applying(transform: Matrix2D) -> SegmentRenderElement<T> {
        self * transform
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        self.renderer.renderSegment(
            start: start * transform,
            end: end * transform,
            in: context,
            scale: scale,
            contextHeight: contextHeight
        )
        if let startElement {
            startElement.render(
                with: Matrix2D(translation: start) * transform,
                in: context,
                scale: scale,
                contextHeight: contextHeight
            )
        }
        if let endElement {
            endElement.render(
                with: Matrix2D(translation: end) * transform,
                in: context,
                scale: scale,
                contextHeight: contextHeight
            )
        }
    }
    
    public func clone() -> SegmentRenderElement<T> {
        SegmentRenderElement<T>(start: start, end: end, renderer: renderer.clone())
    }
}

extension SegmentRenderElement where T == SegmentShape {
    
    public convenience init(start: CGPoint, end: CGPoint, source: SegmentShapeSource, style: ShapeRenderStyle) {
        let renderer = SegmentShape(source: source, style: style)
        self.init(start: start, end: end, renderer: renderer)
    }
}

public func *<T>(lhs: SegmentRenderElement<T>, rhs: Matrix2D) -> SegmentRenderElement<T> {
    return SegmentRenderElement<T>(
        start: lhs.start,
        end: lhs.end,
        transform: lhs.transform * rhs,
        renderer: lhs.renderer
    )
}
