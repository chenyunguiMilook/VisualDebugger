//
//  SegmentShape.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics

public final class SegmentShape: SegmentRenderer {
    
    public var source: SegmentShapeSource
    public var style: ShapeRenderStyle
    
    public init(source: SegmentShapeSource, style: ShapeRenderStyle) {
        self.source = source
        self.style = style
    }
    
    public func renderSegment(
        start: CGPoint,
        end: CGPoint,
        in context: CGContext,
        scale: Double,
        contextHeight: Int?
    ) {
        let path = source.getPath(start: start, end: end)
        context.render(path: path.cgPath, style: style)
    }
    
    public func clone() -> SegmentShape {
        SegmentShape(source: source, style: style)
    }
}
