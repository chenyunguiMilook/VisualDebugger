//
//  SegmentDebugger.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/5.
//

import CoreGraphics
import VisualUtils

public class SegmentDebugger: VertexDebugger {
    public let edgeShape: EdgeShape
    public var edgeStyleDict: [Int: EdgeStyle] = [:]

    public init(
        name: String? = nil,
        transform: Matrix2D,
        color: AppColor,
        vertexShape: VertexDebugger.VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .arrow(Arrow()),
        displayOptions: DisplayOptions = .all,
        labelStyle: TextRenderStyle = .nameLabel,
        useColorfulLable: Bool = false,
        vertexStyleDict: [Int: VertexStyle] = [:],
        edgeStyleDict: [Int: EdgeStyle] = [:]
    ) {
        self.edgeShape = edgeShape
        self.edgeStyleDict = edgeStyleDict
        super.init(
            name: name, 
            transform: transform,
            color: color,
            vertexShape: vertexShape,
            vertexStyleDict: vertexStyleDict,
            displayOptions: displayOptions,
            labelStyle: labelStyle, 
            useColorfulLable: useColorfulLable
        )
    }
    
    func getRadius(index: Int) -> Double {
        let shape = self.vertexStyleDict[index]?.shape ?? vertexShape
        switch shape {
        case .shape(let shape): return shape.radius
        case .index: return 6
        }
    }

    func getEdgeRenderStyle(style: PathStyle?) -> ShapeRenderStyle {
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
    
    func createEdge(
        start: CGPoint,
        end: CGPoint,
        edgeIndex: Int,
        startIndex: Int,
        endIndex: Int
    ) -> SegmentRenderElement {
        let customStyle = edgeStyleDict[edgeIndex]
        let edgeShape = customStyle?.shape ?? self.edgeShape
        let source: SegmentRenderer? = switch edgeShape {
        case .line: nil
        case .arrow(let arrow): arrow
        }
        
        var labelString: String?
        if let edgeLabel = customStyle?.label?.text {
            switch edgeLabel {
            case .string(let string):
                labelString = string
            case .coordinate:
                labelString = "\((start + end) / 2)"
            case .index:
                labelString = "\(edgeIndex)"
            default:
                break
            }
        }
        var label: TextElement?
        if let labelString, let labelStyle = customStyle?.label?.style {
            label = TextElement(text: labelString, style: labelStyle)
        } else {
            label = TextElement(
                text: labelString,
                defaultStyle: labelStyle,
                location: customStyle?.label?.location ?? .center,
                textColor: useColorfulLabel ? customStyle?.style?.color ?? self.color : nil,
                rotatable: customStyle?.label?.rotatable ?? false
            )
        }
        return SegmentRenderElement(
            start: start,
            end: end,
            transform: transform,
            segmentShape: source,
            segmentStyle: getEdgeRenderStyle(style: customStyle?.style),
            centerElement: label,
            offset: customStyle?.offset ?? 0,
            startOffset: getRadius(index: startIndex),
            endOffset: getRadius(index: endIndex)
        )
    }
    
    func getVertices(from points: [CGPoint]) -> [Vertex] {
        points.enumerated().map { (i, point) in
            createVertex(index: i, position: point)
        }
    }
    func getMeshEdges(vertices: [CGPoint], edges: [Edge]) -> [MeshEdge] {
        return edges.enumerated().map { (i, edge) in
            createEdge(
                start: vertices[edge.org],
                end: vertices[edge.dst],
                edgeIndex: i,
                startIndex: edge.org,
                endIndex: edge.dst
            )
        }
    }
}

extension SegmentDebugger {
    public typealias MeshEdge = SegmentRenderElement

    public enum EdgeShape {
        case line
        case arrow(Arrow)
    }
    public struct EdgeStyle {
        let shape: EdgeShape?
        let style: PathStyle?
        let label: LabelStyle?
        let offset: Double?
        
        public init(shape: EdgeShape?, style: PathStyle?, label: LabelStyle?, offset: Double?) {
            self.shape = shape
            self.style = style
            self.label = label
            self.offset = offset
        }
    }
}

extension SegmentDebugger {
    public struct Edge {
        public var org: Int
        public var dst: Int
        
        public init(org: Int, dst: Int) {
            self.org = org
            self.dst = dst
        }
    }
}

extension SegmentDebugger.Edge: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        // 只要是使用的相同的两个顶点，就代表相等，不考虑顶点顺序
        return (lhs.org == rhs.org && lhs.dst == rhs.dst) || (lhs.org == rhs.dst && lhs.dst == rhs.org)
    }
}
