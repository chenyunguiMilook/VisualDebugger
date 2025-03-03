//
//  Points.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class Points {
    public typealias Vertex = PointRenderElement
    public typealias Edge = SegmentRenderElement<SegmentShape>
    
    public enum VertexShape {
        case shape(ShapeType)
        case index
    }
    public enum EdgeShape {
        case line
        case arrow
    }
    
    public let points: [CGPoint]
    public let isClosed: Bool
    public let vertexShape: VertexShape
    public let edgeShape: EdgeShape
    public let color: AppColor
    public let vertexSize: CGSize
    
    public lazy var pointStyle: ShapeRenderStyle = {
        var s = ShapeRenderStyle.arrow
        s.stroke?.color = color
        s.fill?.color = color
        return s
    }()
    
    public lazy var pointTextStyle: TextRenderStyle = {
        TextRenderStyle(
            font: AppFont.italicSystemFont(ofSize: 10),
            insets: .zero,
            margin: AppEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
            anchor: .midCenter,
            textColor: AppColor.white,
            bgStyle: .capsule(color: color, filled: false)
        )
    }()
    
    public lazy var edgeStyle: ShapeRenderStyle = {
        ShapeRenderStyle(
            stroke: .init(color: color, style: .init(lineWidth: 1)),
            fill: nil
        )
    }()
    
    public lazy var vertices: [Vertex] = {
        points.enumerated().map { (i, point) in
            let centerShape: StaticRendable = switch vertexShape {
            case .shape(let shape):
                ShapeElement(source: .shape(shape, size: vertexSize, anchor: .midCenter), style: pointStyle)
            case .index:
                TextElement(source: .index(i), style: pointTextStyle)
            }
            let element = PointElement(shape: centerShape)
            return PointRenderElement(content: element, position: point)
        }
    }()
    
    public lazy var edges: [Edge] = {
        points.segments(isClosed: isClosed).enumerated().map { (i, seg) in
            let source: SegmentShapeSource = switch edgeShape {
            case .line: .line
            case .arrow: .arrow
            }
            // TODO: need set start and end offset
            return Edge(start: seg.start, end: seg.end, source: source, style: edgeStyle)
        }
    }()
    
    public init(
        _ points: [CGPoint],
        isClosed: Bool = true,
        vertexShape: VertexShape = .shape(.circle),
        edgeShape: EdgeShape = .line,
        color: AppColor = .yellow,
        vertexSize: CGSize = CGSize(width: 4, height: 4)
    ) {
        self.points = points
        self.isClosed = isClosed
        self.vertexShape = vertexShape
        self.edgeShape = edgeShape
        self.color = color
        self.vertexSize = vertexSize
    }
}

extension Points: Debuggable {
    public var debugBounds: CGRect? {
        points.bounds
    }
    public func applying(transform: Matrix2D) -> Points {
        Points(
            points * transform,
            isClosed: isClosed,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            color: color,
            vertexSize: vertexSize
        )
    }
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        for edge in edges {
            edge.render(in: context, scale: scale, contextHeight: contextHeight)
        }
        for vtx in vertices {
            vtx.render(in: context, scale: scale, contextHeight: contextHeight)
        }
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    DebugView(elements: [
        Points([
            .init(x: 40, y: 10),
            .init(x: 10, y: 23),
            .init(x: 23, y: 67)
        ], vertexShape: .index)
    ], coordinateSystem: .yDown)
}
