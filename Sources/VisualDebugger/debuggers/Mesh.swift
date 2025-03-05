//
//  Mesh.swift
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

public typealias VMesh = Mesh

public final class Mesh: BaseDebugger {
    
    public typealias MeshEdge = SegmentRenderElement
    public typealias MeshFace = ShapeRenderElement

    // 基本属性
    public let vertices: [CGPoint]
    public let faces: [Face]
    public let edges: [Edge]
    
    // 样式属性
    public var faceStyleDict: [Int: FaceStyle] = [:]
    
    // 缓存的渲染元素
    public lazy var vertexElements: [Vertex] = getVertices()
    public lazy var edgeElements: [MeshEdge] = getMeshEdges()
    public lazy var faceElements: [ShapeRenderElement] = getMeshFaces()
    
    // 初始化方法
    public init(
        _ vertices: [CGPoint],
        faces: [Face],
        transform: Matrix2D = .identity,
        vertexShape: VertexShape = .index,
        edgeShape: EdgeShape = .line,
        color: AppColor = .yellow,
        vertexSize: CGSize = CGSize(width: 4, height: 4),
        vertexStyleDict: [Int: VertexStyle] = [:],
        edgeStyleDict: [Int: EdgeStyle] = [:],
        faceStyleDict: [Int: FaceStyle] = [:],
        displayOptions: DisplayOptions = .all
    ) {
        self.vertices = vertices
        self.faces = faces
        self.edges = Self.getEdges(faces: faces)
        self.faceStyleDict = faceStyleDict

        super.init(
            transform: transform,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            color: color,
            vertexStyleDict: vertexStyleDict,
            edgeStyleDict: edgeStyleDict,
            displayOptions: displayOptions
        )
    }
    
    // 自定义方法：设置顶点样式
    public func overrideVertexStyle(
        at index: Int,
        shape: VertexShape? = nil,
        style: Style? = nil,
        name: Description? = nil,
        nameLocation: TextLocation = .right
    ) -> Mesh {
        guard index < vertices.count else { return self }
        let style = VertexStyle(shape: shape, style: style, name: name, nameLocation: nameLocation)
        self.vertexStyleDict[index] = style
        return self
    }
    
    // 自定义方法：设置边样式
    public func overrideEdgeStyle(
        for edge: Edge,
        shape: EdgeShape? = nil,
        style: Style? = nil,
        name: Description? = nil,
        nameLocation: TextLocation = .right
    ) -> Mesh {
        if let edgeIndex = edges.firstIndex(of: edge) {
            return self.overrideEdgeStyle(
                at: edgeIndex,
                shape: shape,
                style: style,
                name: name,
                nameLocation: nameLocation
            )
        } else {
            return self
        }
    }
    
    public func overrideEdgeStyle(
        at index: Int,
        shape: EdgeShape? = nil,
        style: Style? = nil,
        name: Description? = nil,
        nameLocation: TextLocation = .right
    ) -> Mesh {
        let edgeStyle = EdgeStyle(
            shape: shape,
            style: style,
            name: name,
            nameLocation: nameLocation
        )
        edgeStyleDict[index] = edgeStyle
        return self
    }
    
    // TODO: - need to implement
    // 自定义方法：设置面样式
    public func overrideFaceStyle(
        for face: Face,
        color: AppColor? = nil,
        alpha: CGFloat = 0.3,
        name: Description? = nil,
        nameLocation: TextLocation = .center
    ) -> Mesh {
        guard let faceIndex = faces.firstIndex(of: face) else { return self }
        return self.overrideFaceStyle(
            at: faceIndex,
            color: color,
            alpha: alpha,
            name: name,
            nameLocation: nameLocation
        )
    }
    
    public func overrideFaceStyle(
        at index: Int,
        color: AppColor? = nil,
        alpha: CGFloat = 0.3,
        name: Description? = nil,
        nameLocation: TextLocation = .center
    ) -> Mesh {
        guard index < faces.count else { return self }
        let style = FaceStyle(
            color: color,
            alpha: alpha,
            name: name,
            nameLocation: nameLocation
        )
        self.faceStyleDict[index] = style
        return self
    }
}

extension Mesh {
    // 便利初始化方法，用于从三角形索引数组创建
    public convenience init(
        _ vertices: [CGPoint],
        indices: [Int],
        transform: Matrix2D = .identity,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .line,
        color: AppColor = .yellow
    ) {
        // 验证索引数组的长度是否为3的倍数（每个三角形由3个顶点组成）
        precondition(indices.count % 3 == 0, "索引数组长度必须是3的倍数，以表示三角形面")
        
        // 将平面索引数组转换为Face结构数组
        var faces: [Face] = []
        for i in stride(from: 0, to: indices.count, by: 3) {
            let face = Face(
                indices[i],
                indices[i + 1],
                indices[i + 2]
            )
            faces.append(face)
        }
        
        // 验证所有索引是否在顶点范围内
        let vertexCount = vertices.count
        for face in faces {
            precondition(face.v0 >= 0 && face.v0 < vertexCount, "顶点索引 \(face.v0) 超出范围")
            precondition(face.v1 >= 0 && face.v1 < vertexCount, "顶点索引 \(face.v1) 超出范围")
            precondition(face.v2 >= 0 && face.v2 < vertexCount, "顶点索引 \(face.v2) 超出范围")
        }
        
        self.init(
            vertices,
            faces: faces,
            transform: transform,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            color: color
        )
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 420)) {
    // 示例：创建一个简单的三角形网格
    let vertices = [
        CGPoint(x: 50, y: 50),
        CGPoint(x: 150, y: 50),
        CGPoint(x: 100, y: 150),
        CGPoint(x: 200, y: 150)
    ]
    
    let faces = [
        Mesh.Face(0, 1, 2),
        Mesh.Face(1, 3, 2)
    ]
    
    DebugView(elements: [
        Mesh(vertices, faces: faces)
            .overrideVertexStyle(at: 0, shape: .index, name: .coordinate, nameLocation: .top)
            .overrideVertexStyle(at: 1, style: .init(color: .red), name: .string("顶点1"))
            .overrideEdgeStyle(for: .init(org: 2, dst: 1), style: .init(color: .green))
            //.overrideEdgeStyle(at: 1, color: .red)
            .overrideFaceStyle(at: 0, color: .blue, alpha: 0.2)
    ], showOrigin: true, coordinateSystem: .yDown)
}
