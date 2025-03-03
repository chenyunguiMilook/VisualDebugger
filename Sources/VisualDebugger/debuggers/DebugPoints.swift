//
//  DebugPoints.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

/*
import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Double {
    @usableFromInline
    static let pointRadius: Double = 2
}


public final class DebugPoints {
    
    // TODO: pre-define all points and edges
    public let points: [PointRenderElement]
    public let edges: [EdgeRenderElement]
    public let isClosed: Bool
    
    public private(set) var pointStyle: PointElement
    public private(set) var pointStyleDict: [Int: PointStyle] = [:]
    
    public private(set) var edgeStyle: EdgeStyle
    public private(set) var edgeStyleDict: [Int: EdgeStyle] = [:]
    
    // TOOD: add fill style
    // TOOD: support init from primitives, like polygon, triangle
    
    public init(
        points: [CGPoint],
        isClosed: Bool = true,
        vertexStyle: VertexStyle = .default,
        edgeStyle: EdgeStyle = .arrow(dashed: false),
        color: AppColor = .yellow,
        radius: Double = .pointRadius
    ) {
        self.points = points
        self.isClosed = isClosed
        self.pointStyle = .shape(shape: .circle, color: color)
        switch vertexStyle.style {
        case .shape(let shape):
            self.pointStyle = .shape(shape: shape, color: color, name: nil, radius: radius)
        case .index:
            for i in 0 ..< points.count {
                self.pointStyleDict[i] = .label(LabelStyle("\(i)"), color: color)
            }
        case .label(let label):
            self.pointStyle = .label(label, color: color)
        }
        self.edgeStyle = edgeStyle
    }
    
    public init(
        points: [CGPoint],
        isClosed: Bool,
        pointStyle: PointStyle,
        pointStyleDict: [Int: PointStyle],
        edgeStyle: EdgeStyle,
        edgeStyleDict: [Int: EdgeStyle]
    ) {
        self.points = points
        self.isClosed = isClosed
        self.pointStyle = pointStyle
        self.pointStyleDict = pointStyleDict
        self.edgeStyle = edgeStyle
        self.edgeStyleDict = edgeStyleDict
    }
    
    // TODO: return a dynamicCallable Vertex Style Evironment for easy update common attributes
    public func overrideVertexStyle(
        at index: Int,
        style: VertexStyle,
        color: AppColor? = nil,
        radius: Double = .pointRadius
    ) -> DebugPoints {
        let pointStyle: PointStyle = switch style.style {
        case .shape(let shape):
                .shape(shape: shape, color: color ?? pointStyle.color, name: style.name, radius: radius)
        case .label(let string):
                .label(string, color: color ?? pointStyle.color, name: style.name)
        case .index:
                .label(LabelStyle("\(index)"), color: color ?? pointStyle.color, name: style.name)
        }
        pointStyleDict[index] = pointStyle
        return self
    }
    
    public func overrideEdgeStyle(
        at index: Int,
        style: EdgeStyle
    ) -> DebugPoints {
        edgeStyleDict[index] = style
        return self
    }
}

extension DebugPoints: Debuggable {
    public var debugBounds: CGRect? {
        return points.bounds
    }
    
    public func applying(transform: Matrix2D) -> DebugPoints {
        DebugPoints(
            points: points * transform,
            isClosed: isClosed,
            pointStyle: pointStyle,
            pointStyleDict: pointStyleDict,
            edgeStyle: edgeStyle,
            edgeStyleDict: edgeStyleDict
        )
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        // render edge
        for (i, seg) in points.segments(isClosed: isClosed).enumerated() {
            let style = edgeStyleDict[i] ?? edgeStyle
            switch style {
            case .arrow(let name, let color, let options, let dashed):
                var segment = Segment(start: seg.start, end: seg.end)
                let pointStartStyle = pointStyleDict[i] ?? pointStyle
                let pointEndStyle = pointStyleDict[(i+1+points.count)%points.count] ?? pointStyle
                segment = segment.shrinkingStart(length: pointStartStyle.occupiedWidth)
                segment = segment.shrinkingEnd(length: pointEndStyle.occupiedWidth)
                let element = SegmentRenderElement(
                    color: color ?? pointStyle.color,
                    startPoint: segment.start,
                    endPoint: segment.end,
                    startStyle: options.contains(.start) ? .arrow(style: .triangle, filled: !dashed) : nil,
                    endStyle: options.contains(.end) ? .arrow(style: .triangle, filled: !dashed) : nil,
                    name: name,
                    dash: dashed
                )
                element.render(in: context, scale: scale, contextHeight: contextHeight)
            }
        }
        
        // render point
        for (i, point) in points.enumerated() {
            let style = pointStyleDict[i] ?? pointStyle
            for element in style.getRenderElements(center: point) {
                element.render(in: context, scale: scale, contextHeight: contextHeight)
            }
        }
    }
}
*/

//#Preview(traits: .fixedLayout(width: 400, height: 420)) {
//    //DebugView(debugRect: .init(x: -10, y: -20, width: 100, height: 200))
//    DebugView(elements: [
//        DebugPoints(points: [
//            .init(x: 40, y: 10),
//            .init(x: 10, y: 23),
//            .init(x: 23, y: 67)
//        ], color: .yellow)
//        .overrideVertexStyle(at: 0, style: .shape(.rect.fill, name: "start"))
//        .overrideVertexStyle(at: 1, style: .label("M", name: "middle@bottomLeft"))
//        .overrideVertexStyle(at: 2, style: .label("E@fill", name: "end"), color: .red)
//        .overrideEdgeStyle(at: 2, style: .arrow(name: "edge", color: .green, dashed: true))
//        
//    ], coordinateSystem: .yDown)
//}
