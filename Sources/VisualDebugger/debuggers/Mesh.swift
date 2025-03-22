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

public final class Mesh: GeometryDebugger {
    
    // 基本属性
    public let vertices: [CGPoint]
    public let faces: [Face]
    public let edges: [Edge]
    
    // 缓存的渲染元素
    public lazy var vertexElements: [Vertex] = getVertices()
    public lazy var edgeElements: [MeshEdge] = getMeshEdges(vertices: vertices, edges: edges)
    public lazy var faceElements: [MeshFace] = getMeshFaces()
    
    // 初始化方法
    public init(
        _ vertices: [CGPoint],
        faces: [Face],
        name: String? = nil,
        transform: Matrix2D = .identity,
        vertexShape: VertexShape = .index,
        edgeShape: EdgeShape = .line,
        color: AppColor = .yellow,
        vertexSize: CGSize = CGSize(width: 4, height: 4),
        vertexStyleDict: [Int: VertexStyle] = [:],
        edgeStyleDict: [Int: EdgeStyle] = [:],
        faceStyleDict: [Int: FaceStyle] = [:],
        displayOptions: DisplayOptions = .all,
        labelStyle: TextRenderStyle = .nameLabel,
        useColorfulLabel: Bool = false
    ) {
        self.vertices = vertices
        self.faces = faces
        self.edges = Self.getEdges(faces: faces)

        super.init(
            name: name, 
            transform: transform,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            color: color,
            vertexStyleDict: vertexStyleDict,
            edgeStyleDict: edgeStyleDict,
            faceStyleDict: faceStyleDict,
            displayOptions: displayOptions,
            labelStyle: labelStyle, 
            useColorfulLable: useColorfulLabel
        )
    }
    
    // 自定义方法：设置顶点样式
    public func setVertexStyle(
        at index: Int,
        shape: VertexShape? = nil,
        style: PathStyle? = nil,
        label: LabelStyle? = nil
    ) -> Mesh {
        guard index < vertices.count else { return self }
        let style = VertexStyle(shape: shape, style: style, label: label)
        self.vertexStyleDict[index] = style
        return self
    }
    
    public func setVertexStyle(
        _ style: VertexStyle,
        for indices: Set<Int>
    ) -> Mesh {
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
    ) -> Mesh {
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
    ) -> Mesh {
        let edgeStyle = EdgeStyle(
            shape: shape,
            style: style,
            label: name,
            offset: offset
        )
        edgeStyleDict[index] = edgeStyle
        return self
    }
    
    // TODO: - need to implement
    // 自定义方法：设置面样式
    public func setFaceStyle(
        for face: Face,
        style: PathStyle? = nil,
        label: LabelStyle? = nil
    ) -> Mesh {
        guard let faceIndex = faces.firstIndex(of: face) else { return self }
        return self.setFaceStyle(
            at: faceIndex,
            style: style,
            label: label
        )
    }
    
    public func setFaceStyle(
        at index: Int,
        style: PathStyle? = nil,
        label: LabelStyle? = nil
    ) -> Mesh {
        guard index < faces.count else { return self }
        let style = FaceStyle(
            style: style,
            label: label
        )
        self.faceStyleDict[index] = style
        return self
    }
    
    public func setFaceStyle(
        _ style: FaceStyle,
        for indices: Range<Int>?
    ) -> Mesh {
        let idxs = indices ?? 0 ..< faces.count
        for i in idxs {
            self.faceStyleDict[i] = style
        }
        return self
    }
    
    public func useColorfulLabel(_ value: Bool) -> Self {
        self.useColorfulLabel = value
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
    
    public var indices: [Int] {
        self.faces.map{ [$0.v0, $0.v1, $0.v2] }.flatMap{ $0 }
    }
}

#Preview(traits: .fixedLayout(width: 400, height: 420)) {
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
    
    DebugView(showOrigin: true) {
        Mesh(vertices, faces: faces)
            .setVertexStyle(at: 0, shape: .index, label: .coordinate(at: .top))
            .setVertexStyle(at: 1, style: .init(color: .red), label: "顶点1")
            .setEdgeStyle(for: .init(org: 2, dst: 1), style: .init(color: .green))
            .setFaceStyle(at: 0, style: .init(color: .blue.withAlphaComponent(0.2)), label: .orientation())
            .setFaceStyle(.init(style: nil, label: .orientation()), for: nil)
            .log("faceCount: \(faces.count)")
    }
}
