//
//  Mesh+Debug.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics

extension Mesh: Debuggable {
    public var debugBounds: CGRect? {
        guard let bounds = vertices.bounds else { return nil }
        return bounds * transform
    }
    
    public func applying(transform: Matrix2D) -> Mesh {
        Mesh(
            vertices,
            faces: faces,
            transform: self.transform * transform,
            vertexShape: vertexShape,
            edgeShape: edgeShape,
            color: color,
            vertexSize: vertexSize,
            vertexStyleDict: vertexStyleDict,
            edgeStyleDict: edgeStyleDict,
            faceStyleDict: faceStyleDict
        )
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        // 首先渲染面
        if showFaces {
            for face in faceElements {
                face.render(in: context, scale: scale, contextHeight: contextHeight)
            }
        }
        
        // 然后渲染边
        if showEdges {
            for edge in edgeElements {
                edge.render(in: context, scale: scale, contextHeight: contextHeight)
            }
        }
        
        // 最后渲染顶点
        if showVertices {
            for vertex in vertexElements {
                vertex.render(in: context, scale: scale, contextHeight: contextHeight)
            }
        }
    }
}
