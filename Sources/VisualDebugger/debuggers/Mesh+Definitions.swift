//
//  Mesh+Definitions.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics

extension Mesh {
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
    
    public enum VertexShape {
        case shape(ShapeRenderer)
        case index
    }
    
    public enum Description {
        case string(String)
        case coordinate
        case index
    }
    
    public enum EdgeShape {
        case line
        case arrow(Arrow)
    }
    
    public struct VertexStyle {
        let shape: VertexShape?
        let color: AppColor?
        let name: Description?
        let nameLocation: TextLocation
    }
    
    public struct EdgeStyle {
        let shape: EdgeShape?
        let color: AppColor?
        let name: Description?
        let nameLocation: TextLocation
    }
    
    public struct FaceStyle {
        let color: AppColor?
        let alpha: CGFloat
        let name: Description?
        let nameLocation: TextLocation
    }

}

extension Mesh.Face: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        // 只要是使用的相同的三个顶点，就代表相等，不考虑顶点顺序
        let lhsVertices = Set([lhs.v0, lhs.v1, lhs.v2])
        let rhsVertices = Set([rhs.v0, rhs.v1, rhs.v2])
        return lhsVertices == rhsVertices
    }
}

extension Mesh.Edge: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        // 只要是使用的相同的两个顶点，就代表相等，不考虑顶点顺序
        return (lhs.org == rhs.org && lhs.dst == rhs.dst) || (lhs.org == rhs.dst && lhs.dst == rhs.org)
    }
}
