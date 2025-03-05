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
    public var startElement: PointElement?
    public var endElement: PointElement?
    public var topElement: TextElement? // edge center 90 degree direction
    public var bottomElement: TextElement? // edge center -90 degree direction
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
        startElement: PointElement? = nil,
        endElement: PointElement? = nil,
        topElement: TextElement? = nil,  // edge center 90 degree direction
        bottomElement: TextElement? = nil,  // edge center -90 degree direction
        startOffset: Double = 0,
        endOffset: Double = 0
    ) {
        self.start = start
        self.end = end
        self.transform = transform
        self.segmentShape = segmentShape
        self.segmentStyle = segmentStyle
        self.startElement = startElement
        self.endElement = endElement
        self.topElement = topElement
        self.bottomElement = bottomElement
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
        if let topElement {
            topElement.render(
                with: Matrix2D(translation: (start + end)/2.0) * transform,
                in: context,
                scale: scale,
                contextHeight: contextHeight
            )
        }
        if let bottomElement {
            bottomElement.render(
                with: Matrix2D(translation: (start + end)/2.0) * transform,
                in: context,
                scale: scale,
                contextHeight: contextHeight
            )
        }
    }
}

public func *(lhs: SegmentRenderElement, rhs: Matrix2D) -> SegmentRenderElement {
    let seg = SegmentRenderElement(
        start: lhs.start,
        end: lhs.end,
        transform: lhs.transform * rhs,
        segmentShape: lhs.segmentShape,
        segmentStyle: lhs.segmentStyle,
        startOffset: lhs.startOffset,
        endOffset: lhs.endOffset
    )
    seg.startElement = lhs.startElement
    seg.endElement = lhs.endElement
    seg.topElement = lhs.topElement
    seg.bottomElement = lhs.bottomElement
    return seg
}
