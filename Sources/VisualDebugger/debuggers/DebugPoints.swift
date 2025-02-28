//
//  DebugPoints.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class DebugPoints {
    public enum VertexStyle {
        case shape(PointStyle.Shape, name: String? = nil)
        case label(String, name: String? = nil)
        case index(name: String? = nil)
    }
    public enum EdgeStyle { // for each pair of vertics
        public struct ArrowOptions: OptionSet, Sendable {
            public var rawValue: Int
            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
            public static let start = Self(rawValue: 1 << 0)
            public static let end = Self(rawValue: 1 << 1)
            public static let all: Self = [.start, .end]
        }
        case arrow(name: String? = nil, color: AppColor? = nil, options: ArrowOptions = .end, dashed: Bool = false)
    }
    
    public let points: [CGPoint]
    public let isClosed: Bool
    
    public private(set) var pointStyle: PointStyle!
    public private(set) var pointStyleDict: [Int: PointStyle] = [:]
    
    public private(set) var edgeStyle: EdgeStyle!
    public private(set) var edgeStyleDict: [Int: EdgeStyle] = [:]
    
    // TOOD: add fill style
    // TOOD: support init from primitives, like polygon, triangle
    
    public init(
        points: [CGPoint],
        isClosed: Bool = true,
        vertexStyle: VertexStyle = .shape(.circle),
        edgeStyle: EdgeStyle = .arrow(dashed: false),
        color: AppColor = .yellow,
        radius: Double = .pointRadius,
        filled: Bool = .shapeFilled
    ) {
        self.points = points
        self.isClosed = isClosed
        switch vertexStyle {
        case .shape(let shape, _):
            self.pointStyle = .shape(shape: shape, color: color, name: nil, radius: radius, filled: filled)
        case .index:
            for i in 0 ..< points.count {
                self.pointStyleDict[i] = .label("\(i)", color: color)
            }
        case .label(let string, _):
            self.pointStyle = .label(string, color: color)
        }
        self.edgeStyle = edgeStyle
    }
    
    public init(
        points: [CGPoint],
        isClosed: Bool,
        pointStyle: PointStyle,
        pointStyleDict: [Int: PointStyle],
        edgeStyle: EdgeStyle?,
        edgeStyleDict: [Int: EdgeStyle]
    ) {
        self.points = points
        self.isClosed = isClosed
        self.pointStyle = pointStyle
        self.pointStyleDict = pointStyleDict
        self.edgeStyle = edgeStyle
        self.edgeStyleDict = edgeStyleDict
    }
    
    public func overrideVertexStyle(
        at index: Int,
        style: VertexStyle,
        color: AppColor? = nil,
        radius: Double = .pointRadius,
        shapeFilled: Bool = .shapeFilled,
        labelFilled: Bool = .labelFilled
    ) -> DebugPoints {
        let pointStyle: PointStyle = switch style {
        case .shape(let shape, let name):
                .shape(shape: shape, color: color ?? pointStyle.color, name: name, radius: radius, filled: shapeFilled)
        case .label(let string, let name):
                .label(string, color: color ?? pointStyle.color, name: name, filled: labelFilled)
        case .index(let name):
                .label("\(index)", color: color ?? pointStyle.color, name: name, filled: labelFilled)
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
            guard let style = edgeStyleDict[i] ?? edgeStyle else { continue }
            switch style {
            case .arrow(let name, let color, let options, let dashed):
                var segment = Segment(start: seg.start, end: seg.end)
                let pointStartStyle = pointStyleDict[i] ?? pointStyle!
                let pointEndStyle = pointStyleDict[(i+1+points.count)%points.count] ?? pointStyle!
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
            let style = pointStyleDict[i] ?? pointStyle!
            for element in style.getRenderElements(center: point) {
                element.render(in: context, scale: scale, contextHeight: contextHeight)
            }
        }
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    //DebugView(debugRect: .init(x: -10, y: -20, width: 100, height: 200))
    DebugView(elements: [
        DebugPoints(points: [
            .init(x: 40, y: 10),
            .init(x: 10, y: 23),
            .init(x: 23, y: 67)
        ], color: .yellow)
        .overrideVertexStyle(at: 0, style: .shape(.rect, name: "start"))
        .overrideVertexStyle(at: 1, style: .label("A", name: "end"), color: .red)
        .overrideVertexStyle(at: 2, style: .shape(.circle, name: "middle"))
        .overrideEdgeStyle(at: 0, style: .arrow(color: .green, dashed: true))
        
    ], coordinateSystem: .yDown)
}
