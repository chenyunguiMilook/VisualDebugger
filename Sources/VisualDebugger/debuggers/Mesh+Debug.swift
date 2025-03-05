//
//  Mesh+Debug.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics

extension Mesh: Transformable, Debuggable {
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
            vertexStyleDict: vertexStyleDict,
            edgeStyleDict: edgeStyleDict,
            faceStyleDict: faceStyleDict,
            displayOptions: displayOptions
        )
    }
    
    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        // 首先渲染面
        // TODO: need to fix
        if displayOptions.contains(.face) {
            for face in faceElements {
                face.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
            }
        }
        
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
