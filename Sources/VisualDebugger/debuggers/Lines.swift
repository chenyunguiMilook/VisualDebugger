//
//  Lines.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/11.
//

import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class Lines: SegmentDebugger {
    
    // 基本属性
    public let vertices: [CGPoint]
    public let edges: [Edge]
    
    // 缓存的渲染元素
    public lazy var vertexElements: [Vertex] = getVertices(from: vertices)
    public lazy var edgeElements: [MeshEdge] = getMeshEdges(vertices: vertices, edges: edges)
    
    // 初始化方法
    public init(
        _ vertices: [CGPoint],
        indices: [Int],
        name: String? = nil,
        transform: Matrix2D = .identity,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .line,
        color: AppColor = .yellow,
        vertexStyleDict: [Int: VertexStyle] = [:],
        edgeStyleDict: [Int: EdgeStyle] = [:],
        displayOptions: DisplayOptions = .all,
        labelStyle: TextRenderStyle = .nameLabel,
        useColorfulLabel: Bool = false
    ) {
        // 验证索引数组的长度是否为2的倍数（每条线段由2个顶点组成）
        precondition(indices.count % 2 == 0, "索引数组长度必须是2的倍数，以表示线段")
        
        self.vertices = vertices
        
        // 将平面索引数组转换为Edge数组
        var edges: [Edge] = []
        for i in stride(from: 0, to: indices.count, by: 2) {
            let edge = Edge(org: indices[i], dst: indices[i + 1])
            edges.append(edge)
        }
        
        // 验证所有索引是否在顶点范围内
        let vertexCount = vertices.count
        for edge in edges {
            precondition(edge.org >= 0 && edge.org < vertexCount, "顶点索引 \(edge.org) 超出范围")
            precondition(edge.dst >= 0 && edge.dst < vertexCount, "顶点索引 \(edge.dst) 超出范围")
        }
        
        self.edges = edges
        
        super.init(
            name: name, 
            transform: transform,
            color: color,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            displayOptions: displayOptions,
            labelStyle: labelStyle,
            useColorfulLable: useColorfulLabel,
            vertexStyleDict: vertexStyleDict,
            edgeStyleDict: edgeStyleDict
        )
    }
    
    // 自定义方法：设置顶点样式
    public func setVertexStyle(
        at index: Int,
        shape: VertexShape? = nil,
        style: PathStyle? = nil,
        label: LabelStyle? = nil
    ) -> Lines {
        guard index < vertices.count else { return self }
        let style = VertexStyle(shape: shape, style: style, label: label)
        self.vertexStyleDict[index] = style
        return self
    }
    
    public func setVertexStyle(
        _ style: VertexStyle,
        for indices: Set<Int>
    ) -> Lines {
        for index in indices where index < vertices.count {
            self.vertexStyleDict[index] = style
        }
        return self
    }

    // 自定义方法：设置边样式
    public func setEdgeStyle(
        for edge: Edge,
        shape: EdgeShape? = nil,
        style: PathStyle? = nil,
        label: LabelStyle? = nil
    ) -> Lines {
        if let edgeIndex = edges.firstIndex(of: edge) {
            return self.setEdgeStyle(
                at: edgeIndex,
                shape: shape,
                style: style,
                name: label
            )
        } else {
            return self
        }
    }
    
    public func setEdgeStyle(
        at index: Int,
        shape: EdgeShape? = nil,
        style: PathStyle? = nil,
        name: LabelStyle? = nil,
        offset: Double? = nil
    ) -> Lines {
        let edgeStyle = EdgeStyle(
            shape: shape,
            style: style,
            label: name,
            offset: offset
        )
        edgeStyleDict[index] = edgeStyle
        return self
    }
    
    // MARK: - modifier
    public func show(_ option: DisplayOptions) -> Self {
        self.displayOptions = option
        return self
    }
    
    public func log(_ message: String, _ level: Logger.Log.Level = .info) -> Self {
        self.logging(message, level)
        return self
    }
}

extension Lines {
    public var indices: [Int] {
        self.edges.map{ [$0.org, $0.dst] }.flatMap{ $0 }
    }
}

extension Lines: DebugRenderable {
    public var debugBounds: CGRect? {
        guard let bounds = vertices.bounds else { return nil }
        return bounds * transform
    }
        
    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        // 然后渲染边
        if displayOptions.contains(.edge) {
            for edge in edgeElements {
                edge.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
            }
        }
        
        // 最后渲染顶点
        if displayOptions.contains(.vertex) {
            for vertex in vertexElements {
                vertex.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
            }
        }
    }
}


#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    let vertices = [
        CGPoint(x: 50, y: 50),
        CGPoint(x: 150, y: 50),
        CGPoint(x: 100, y: 150),
        CGPoint(x: 200, y: 150)
    ]
    
    let indices = [0, 1, 1, 2, 2, 3] // 三条连续的线段
    
    DebugView(showOrigin: true) {
        Lines(vertices, indices: indices)
            .setVertexStyle(at: 0, shape: .index, label: .coordinate(at: .top))
            .setVertexStyle(at: 1, style: .init(color: .red), label: "顶点1")
            .setEdgeStyle(for: .init(org: 2, dst: 3), style: .init(color: .green))
            .show([.vertex, .edge])
    }
} 
