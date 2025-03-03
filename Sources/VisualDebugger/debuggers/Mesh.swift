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

public final class Mesh {
    
    public typealias Vertex = PointRenderElement
    public typealias MeshEdge = SegmentRenderElement<SegmentShape>
    public typealias MeshFace = ShapeRenderElement

    // 基本属性
    public let vertices: [CGPoint]
    public let faces: [Face]
    public let transform: Matrix2D
    
    // 样式属性
    public let vertexShape: VertexShape
    public let edgeShape: EdgeShape
    public let color: AppColor
    public let vertexSize: CGSize
    public var vertexStyleDict: [Int: VertexStyle]
    public var edgeStyleDict: [Int: EdgeStyle] = [:]
    public var faceStyleDict: [Int: FaceStyle] = [:]
    
    // 是否显示顶点、边、面
    public var showVertices: Bool = true
    public var showEdges: Bool = true
    public var showFaces: Bool = false
    
    // 缓存的渲染元素
    public lazy var vertexElements: [Vertex] = getVertices()
    public lazy var edgeElements: [MeshEdge] = getMeshEdges()
    public lazy var faceElements: [ShapeRenderElement] = getMeshFaces()
    
    // 辅助函数
    func vertexStyle(color: AppColor) -> ShapeRenderStyle {
        ShapeRenderStyle(
            fill: .init(color: color, style: .init())
        )
    }

    func edgeStyle(color: AppColor) -> ShapeRenderStyle {
        ShapeRenderStyle(
            stroke: .init(color: color, style: .init(lineWidth: 1)),
            fill: nil
        )
    }
    
    func labelStyle(color: AppColor) -> TextRenderStyle {
        TextRenderStyle(
            font: AppFont.italicSystemFont(ofSize: 10),
            insets: .zero,
            margin: AppEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
            anchor: .midCenter,
            textColor: color,
            bgStyle: .capsule(color: color, filled: false)
        )
    }
    
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
        faceStyleDict: [Int: FaceStyle] = [:]
    ) {
        self.vertices = vertices
        self.faces = faces
        self.transform = transform
        self.vertexShape = vertexShape
        self.edgeShape = edgeShape
        self.color = color
        self.vertexSize = vertexSize
        self.vertexStyleDict = vertexStyleDict
        self.edgeStyleDict = edgeStyleDict
        self.faceStyleDict = faceStyleDict
    }
    
    
    
    // 获取指定索引顶点的半径
    func getRadius(index: Int) -> Double {
        let shape = self.vertexStyleDict[index]?.shape ?? vertexShape
        switch shape {
        case .shape: return vertexSize.width / 2.0
        case .index: return 6
        }
    }
    
    // 创建顶点渲染元素
    func createVertex(
        index: Int,
        position: CGPoint,
        shape: VertexShape?,
        color: AppColor?,
        name: String?,
        nameLocation: TextLocation = .right,
        transform: Matrix2D
    ) -> Vertex {
        let shape = shape ?? self.vertexShape
        let color = color ?? self.color
        let centerShape: StaticRendable = switch shape {
        case .shape(let shape):
            ShapeElement(source: .shape(shape, size: vertexSize, anchor: .midCenter), style: vertexStyle(color: color))
        case .index:
            TextElement(source: .index(index), style: labelStyle(color: color))
        }
        var label: TextElement?
        if let name {
            var style: TextRenderStyle = .nameLabel
            style.setTextLocation(nameLocation)
            label = TextElement(source: .string(name), style: style)
        }
        let element = PointElement(shape: centerShape, label: label)
        return PointRenderElement(content: element, position: position, transform: transform)
    }
    
    // 自定义方法：设置顶点样式
    public func overrideVertexStyle(
        at index: Int,
        shape: VertexShape? = nil,
        color: AppColor? = nil,
        name: Description? = nil,
        nameLocation: TextLocation = .right
    ) -> Mesh {
        guard index < vertices.count else { return self }
        let style = VertexStyle(shape: shape, color: color, name: name, nameLocation: nameLocation)
        self.vertexStyleDict[index] = style
        return self
    }
    
    // 自定义方法：设置边样式
    public func overrideEdgeStyle(
        for edge: Edge,
        shape: EdgeShape? = nil,
        color: AppColor? = nil,
        name: Description? = nil,
        nameLocation: TextLocation = .right
    ) -> Mesh {
        if let edgeIndex = edgeElements.firstIndex(where: { $0.start == vertices[edge.org] && $0.end == vertices[edge.dst] }) {
            let edgeStyle = EdgeStyle(
                shape: shape,
                color: color,
                name: name,
                nameLocation: nameLocation
            )
            edgeStyleDict[edgeIndex] = edgeStyle
        }
        return self
    }
    
    // TODO: - need to implement
    // 自定义方法：设置面样式
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
    
    // 设置显示选项
    public func setDisplay(vertices: Bool = true, edges: Bool = true, faces: Bool = false) -> Mesh {
        self.showVertices = vertices
        self.showEdges = edges
        self.showFaces = faces
        return self
    }
}

extension Mesh {
    // 便利初始化方法，用于从三角形索引数组创建
    public convenience init(
        _ vertices: [CGPoint],
        indices: [Int],
        transform: Matrix2D = .identity,
        vertexShape: VertexShape = .shape(.circle),
        edgeShape: EdgeShape = .line,
        color: AppColor = .yellow,
        vertexSize: CGSize = CGSize(width: 4, height: 4)
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
            color: color,
            vertexSize: vertexSize
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
    
    return DebugView(elements: [
        Mesh(vertices, faces: faces)
            .overrideVertexStyle(at: 0, shape: .index, name: .coordinate, nameLocation: .top)
            .overrideVertexStyle(at: 1, color: .red, name: .string("顶点1"))
            .overrideEdgeStyle(for: .init(org: 1, dst: 2), color: .red)
            .overrideFaceStyle(at: 0, color: .blue, alpha: 0.2)
            .setDisplay(vertices: true, edges: true, faces: true)
    ], showOrigin: true, coordinateSystem: .yDown)
}
