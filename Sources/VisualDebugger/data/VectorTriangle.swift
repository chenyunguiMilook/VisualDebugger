//
//  VectorTriangle.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/11.
//

import CoreGraphics

public struct VectorTriangle {
    public var segment: Bezier3Segment
    public var vertex: CGPoint
    
    public init(segment: Bezier3Segment, vertex: CGPoint) {
        self.segment = segment
        self.vertex = vertex
    }
}
