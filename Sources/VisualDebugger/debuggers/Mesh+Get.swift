//
//  Mesh+Get.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

extension Mesh {
    
    func getVertices() -> [Vertex] {
        getVertices(from: self.vertices)
    }

    func getMeshEdges() -> [MeshEdge] {
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
    
    func getMeshFaces() -> [MeshFace] {
        faces.enumerated().map { (i, face) in
            createFace(
                vertices: [vertices[face.v0], vertices[face.v1], vertices[face.v2]],
                faceIndex: i
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
