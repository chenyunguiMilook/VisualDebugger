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
        case shape(ShapeType)
        case index
    }
    
    public enum Description {
        case string(String)
        case coordinate
        case index
    }
    
    public enum EdgeShape {
        case line
        case arrow(style: ArrowStyle, direction: ArrowDirection)
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
