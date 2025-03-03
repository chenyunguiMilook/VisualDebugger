//
//  Mesh+Get.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

extension Mesh {
    
    func getVertices() -> [Vertex] {
        vertices.enumerated().map { (i, point) in
            if let style = vertexStyleDict[i] {
                var nameString: String?
                if let name = style.name {
                    switch name {
                    case .string(let string):
                        nameString = string
                    case .coordinate:
                        nameString = "(\(point.x), \(point.y))"
                    case .index:
                        nameString = "\(i)"
                    }
                }
                return createVertex(
                    index: i,
                    position: point,
                    shape: style.shape,
                    color: style.color,
                    name: nameString,
                    nameLocation: style.nameLocation,
                    transform: transform
                )
            } else {
                return createVertex(
                    index: i,
                    position: point,
                    shape: nil,
                    color: nil,
                    name: nil,
                    transform: transform
                )
            }
        }
    }

    func getMeshEdges() -> [MeshEdge] {
        return edges.enumerated().map { (i, edge) in
            // 获取样式，优先使用自定义样式，否则使用默认样式
            let customStyle = edgeStyleDict[i]
            let edgeShape = customStyle?.shape ?? self.edgeShape
            let edgeColor = customStyle?.color ?? self.color
            
            // 根据边形状创建对应的SegmentShapeSource
            let source: SegmentShapeSource = switch edgeShape {
            case .line: .line
            case .arrow(let style, let direction): .arrow(style: style, direction: direction)
            }
            
            let startIndex = edge.org
            let endIndex = edge.dst
            
            return MeshEdge(
                start: vertices[startIndex],
                end: vertices[endIndex],
                transform: transform,
                source: source,
                style: edgeStyle(color: edgeColor),
                startOffset: getRadius(index: startIndex),
                endOffset: getRadius(index: endIndex)
            )
        }
    }
    
    func getMeshFaces() -> [MeshFace] {
        faces.enumerated().map { (i, face) in
            let style = faceStyleDict[i]
            let faceColor = style?.color ?? self.color.withAlphaComponent(0.3)
            let path = AppBezierPath()
            path.move(to: vertices[face.v0])
            path.addLine(to: vertices[face.v1])
            path.addLine(to: vertices[face.v2])
            path.close()
            
            return ShapeRenderElement(
                path: path,
                style: ShapeRenderStyle(fill: .init(color: faceColor))
            )
        }
    }
    
    // 从Face数据生成唯一的边
    static func getEdges(faces: [Face]) -> [Edge] {
        // 使用Set来跟踪唯一的边
        var edgeSet: Set<String> = Set()
        var edges: [Edge] = []
        
        // 处理每个面
        for face in faces {
            // 为这个三角形创建三条边
            let edgePairs = [
                (face.v0, face.v1),
                (face.v1, face.v2),
                (face.v2, face.v0)
            ]
            
            for (start, end) in edgePairs {
                // 创建不考虑方向的唯一标识符，总是较小的索引在前
                let orderedPair = start < end ? "\(start)-\(end)" : "\(end)-\(start)"
                
                // 如果这条边是新的，就添加它
                if edgeSet.insert(orderedPair).inserted {
                    let edge = Edge(org: start, dst: end)
                    edges.append(edge)
                }
            }
        }
        
        return edges
    }
}
