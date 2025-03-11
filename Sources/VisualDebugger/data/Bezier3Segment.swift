//
//  Bezier3Segment.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/11.
//

import CoreGraphics

public struct Bezier3Segment {
    public var start: CGPoint
    public var control1: CGPoint
    public var control2: CGPoint
    public var end: CGPoint
    
    public init(start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint) {
        self.start = start
        self.control1 = control1
        self.control2 = control2
        self.end = end
    }
}

