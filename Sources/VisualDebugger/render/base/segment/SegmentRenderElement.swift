//
//  SegmentElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics
import VisualUtils

public final class SegmentRenderElement: ContextRenderable {
    
    public let start: CGPoint
    public let end: CGPoint
    public let transform: Matrix2D
    public var startElement: PointElement?
    public var endElement: PointElement?
    public var centerElement: TextElement?
    public var offset: Double = 0 // rendering offset, 90 degree direction is positive
    public var startOffset: Double = 0 // shrink or expand start
    public var endOffset: Double = 0 // shrink or expand end
    public var segmentShape: SegmentRenderer?
    public var segmentStyle: ShapeRenderStyle
    
    var angle: Double {
        (end - start).angle
    }
    var center: CGPoint {
        (start + end) / 2.0
    }
    
    public init(
        start: CGPoint,
        end: CGPoint,
        transform: Matrix2D = .identity,
        segmentShape: SegmentRenderer?,
        segmentStyle: ShapeRenderStyle,
        startElement: PointElement? = nil,
        endElement: PointElement? = nil,
        centerElement: TextElement? = nil,
        offset: Double = 0,
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
        self.centerElement = centerElement
        self.offset = offset
        self.startOffset = startOffset
        self.endOffset = endOffset
    }
    
    public func render(with matrix: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        let transform = self.transform * matrix
        let s = start * transform
        let e = end * transform
        var seg = Segment(start: s, end: e)
        seg = seg.offseting(distance: offset)
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
        if let centerElement {
            let rotateM = Matrix2D(rotationAngle: seg.angle)
            let moveM = Matrix2D(translation: seg.center)
            centerElement.render(
                with: rotateM * moveM,
                in: context,
                scale: scale,
                contextHeight: contextHeight
            )
        }
    }
}
