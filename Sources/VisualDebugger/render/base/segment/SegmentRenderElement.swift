//
//  SegmentElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics

public final class SegmentRenderElement: Transformable, ContextRenderable {
    
    public let start: CGPoint
    public let end: CGPoint
    public let transform: Matrix2D
    public var startElement: StaticRendable?
    public var endElement: StaticRendable?
    public var startOffset: Double = 0
    public var endOffset: Double = 0
    public var segmentShape: SegmentRenderer? // rename to segmentShape
    public var segmentStyle: ShapeRenderStyle
    
    public init(
        start: CGPoint,
        end: CGPoint,
        transform: Matrix2D = .identity,
        segmentShape: SegmentRenderer?,
        segmentStyle: ShapeRenderStyle,
        startOffset: Double = 0,
        endOffset: Double = 0
    ) {
        self.start = start
        self.end = end
        self.transform = transform
        self.segmentShape = segmentShape
        self.segmentStyle = segmentStyle
        self.startOffset = startOffset
        self.endOffset = endOffset
    }
    
    public func applying(transform: Matrix2D) -> SegmentRenderElement {
        self * transform
    }
    
    public func render(with matrix: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        let transform = self.transform * matrix
        let s = start * transform
        let e = end * transform
        var seg = Segment(start: s, end: e)
        seg = seg.shrinkingStart(length: startOffset)
        seg = seg.shrinkingEnd(length: endOffset)
        
        let path: AppBezierPath
        if let segmentShape {
            path = segmentShape.getBezierPath(start: seg.start, end: seg.end)
        } else {
            path = AppBezierPath()
            path.move(to: seg.start)
            path.addLine(to: seg.end)
        }
        context.render(path: path.cgPath, style: segmentStyle)
        
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
}

public func *(lhs: SegmentRenderElement, rhs: Matrix2D) -> SegmentRenderElement {
    return SegmentRenderElement(
        start: lhs.start,
        end: lhs.end,
        transform: lhs.transform * rhs,
        segmentShape: lhs.segmentShape,
        segmentStyle: lhs.segmentStyle,
        startOffset: lhs.startOffset,
        endOffset: lhs.endOffset
    )
}
