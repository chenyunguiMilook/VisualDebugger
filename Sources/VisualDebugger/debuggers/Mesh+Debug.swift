//
//  Mesh+Debug.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics
import VisualUtils

extension Mesh: DebugRenderable {
    public var debugBounds: CGRect? {
        guard let bounds = vertices.bounds else { return nil }
        return bounds * transform
    }
    
    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        let matrix = self.transform * transform
        // 首先渲染面
        // TODO: need to fix
        if displayOptions.contains(.face) {
            for face in faceElements {
                face.render(with: matrix, in: context, scale: scale, contextHeight: contextHeight)
            }
        }
        
        // 然后渲染边
        if displayOptions.contains(.edge) {
            for edge in edgeElements {
                edge.render(with: matrix, in: context, scale: scale, contextHeight: contextHeight)
            }
        }
        
        // 最后渲染顶点
        if displayOptions.contains(.vertex) {
            for vertex in vertexElements {
                vertex.render(with: matrix, in: context, scale: scale, contextHeight: contextHeight)
            }
        }
    }
}
