//
//  SegmentDebugger.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/5.
//

public class SegmentDebugger: VertexDebugger {
    public let edgeShape: EdgeShape

    public init(
        transform: Matrix2D,
        color: AppColor,
        vertexShape: VertexDebugger.VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .arrow(Arrow())
    ) {
        self.edgeShape = edgeShape
        super.init(
            transform: transform,
            color: color,
            vertexShape: vertexShape
        )
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
