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
    
}

extension Mesh.Face: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        // 只要是使用的相同的三个顶点，就代表相等，不考虑顶点顺序
        let lhsVertices = Set([lhs.v0, lhs.v1, lhs.v2])
        let rhsVertices = Set([rhs.v0, rhs.v1, rhs.v2])
        return lhsVertices == rhsVertices
    }
}

