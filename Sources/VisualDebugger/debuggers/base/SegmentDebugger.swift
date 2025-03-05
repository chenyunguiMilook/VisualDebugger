//
//  SegmentDebugger.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/5.
//

import CoreGraphics

public class SegmentDebugger: VertexDebugger {
    public let edgeShape: EdgeShape
    public var vertexStyleDict: [Int: VertexStyle]

    public init(
        name: String? = nil,
        transform: Matrix2D,
        color: AppColor,
        vertexShape: VertexDebugger.VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .arrow(Arrow()),
        displayOptions: DisplayOptions = .all,
        vertexStyleDict: [Int: VertexStyle] = [:]
    ) {
        self.edgeShape = edgeShape
        self.vertexStyleDict = vertexStyleDict
        super.init(
            name: name, 
            transform: transform,
            color: color,
            vertexShape: vertexShape,
            displayOptions: displayOptions
        )
    }
    
    func getRadius(index: Int) -> Double {
        let shape = self.vertexStyleDict[index]?.shape ?? vertexShape
        switch shape {
        case .shape(let shape): return shape.radius
        case .index: return 6
        }
    }

    func edgeStyle(style: Style?) -> ShapeRenderStyle {
        let color = style?.color ?? color
        guard let mode = style?.mode else {
            return ShapeRenderStyle(
                stroke: .init(color: color, style: .init(lineWidth: 1)),
                fill: nil
            )
        }
        switch mode {
        case .stroke(dashed: let dashed):
            let dash: [CGFloat] = dashed ? [5, 5] : []
            return ShapeRenderStyle(
                stroke: .init(color: color, style: .init(lineWidth: 1, dash: dash)),
                fill: .init(color: color, style: .init())
            )
        case .fill:
            return ShapeRenderStyle(
                stroke: .init(color: color, style: .init(lineWidth: 1)),
                fill: .init(color: color, style: .init())
            )
        }
    }
}

extension SegmentDebugger {
    
    public typealias Edge = SegmentRenderElement

    public enum EdgeShape {
        case line
        case arrow(Arrow)
    }
    public struct EdgeStyle {
        let shape: EdgeShape?
        let style: Style?
        let label: Description?
    }
}
