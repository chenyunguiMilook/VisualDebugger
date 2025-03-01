//
//  DebugMesh.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/28.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class DebugMesh {
    public struct Face {
        public var v0: Int
        public var v1: Int
        public var v2: Int
        
        public init(_ v0: Int, _ v1: Int, _ v2: Int) {
            self.v0 = v0
            self.v1 = v1
            self.v2 = v2
        }
    }
    public struct Edge {
        public var org: Int
        public var dst: Int

        public init(org: Int, dst: Int) {
            self.org = org
            self.dst = dst
        }
    }
    
    public let vertices: [CGPoint]
    public let faces: [Face] // face structure
    
    public private(set) var pointStyle: PointStyle = .shape(shape: .circle, color: .yellow)
    public private(set) var pointStyleDict: [Int: PointStyle] = [:]
    
    public init(
        vertices: [CGPoint],
        faces: [Face],
        vertexStyle: VertexStyle = .default,
        edgeStyle: EdgeStyle = .arrow(dashed: false),
        color: AppColor = .yellow
    ) {
        self.vertices = vertices
        self.faces = faces
        self.pointStyle = .shape(shape: .circle, color: color)
        switch vertexStyle.style {
        case .index:
            for i in 0 ..< vertices.count {
                self.pointStyleDict[i] = .label(LabelStyle("\(i)"), color: color)
            }
        case .shape(let shape):
            self.pointStyle = .shape(shape: shape, color: color, name: nil)
        default:
            break
        }
    }
    
    public init(
        vertices: [CGPoint],
        faces: [Face],
        pointStyle: PointStyle,
        pointStyleDict: [Int: PointStyle]
    ) {
        self.vertices = vertices
        self.faces = faces
        self.pointStyle = pointStyle
        self.pointStyleDict = pointStyleDict
    }
    
    public func overrideVertexStyle(
        at index: Int,
        style: VertexStyle,
        color: AppColor? = nil,
        radius: Double = .pointRadius
    ) -> DebugMesh {
        let pointStyle: PointStyle = switch style.style {
        case .shape(let shape):
                .shape(shape: shape, color: color ?? pointStyle.color, name: style.name, radius: radius)
        case .label(let label):
                .label(label, color: color ?? pointStyle.color, name: style.name)
        case .index:
                .label(LabelStyle("\(index)"), color: color ?? pointStyle.color, name: style.name)
        }
        pointStyleDict[index] = pointStyle
        return self
    }
    
    public func highlightFace(
        at index: Int
    ) -> DebugMesh {
        // need implementation
        return self
    }
    
    func getEdges() -> [Edge] {
        // 使用 Set 来跟踪唯一的边
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
                // 创建一个不考虑方向的唯一标识符，总是较小的索引在前
                let orderedPair = start < end ? "\(start)-\(end)" : "\(end)-\(start)"
                
                // 如果这条边是新的，就添加它
                if edgeSet.insert(orderedPair).inserted {
                    let edge = Edge(org: start, dst: end)
                    edges.append(edge)
                }
            }
        }
        
        return edges
    }}

extension DebugMesh: Debuggable {
    public var debugBounds: CGRect? {
        return vertices.bounds
    }
    
    public func applying(transform: Matrix2D) -> DebugMesh {
        DebugMesh(
            vertices: vertices * transform,
            faces: faces,
            pointStyle: pointStyle,
            pointStyleDict: pointStyleDict
        )
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        // render edge
        for edge in getEdges() {
            var segment = Segment(start: vertices[edge.org], end: vertices[edge.dst])
            let pointStartStyle = pointStyleDict[edge.org] ?? pointStyle
            let pointEndStyle = pointStyleDict[edge.dst] ?? pointStyle
            segment = segment.shrinkingStart(length: pointStartStyle.occupiedWidth)
            segment = segment.shrinkingEnd(length: pointEndStyle.occupiedWidth)
            let element = SegmentRenderElement(
                color: pointStyle.color,
                startPoint: segment.start,
                endPoint: segment.end,
                startStyle: nil,
                endStyle: nil,
                name: nil
            )
            element.render(in: context, scale: scale, contextHeight: contextHeight)
        }
        
        // render point
        for (i, point) in vertices.enumerated() {
            let style = pointStyleDict[i] ?? pointStyle
            for element in style.getRenderElements(center: point) {
                element.render(in: context, scale: scale, contextHeight: contextHeight)
            }
        }
    }
}
