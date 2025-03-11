//
//  VectorTriangle.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/11.
//

import CoreGraphics

public typealias VVectorTriangle = VectorTriangle
public struct VectorTriangle {
    public struct Segment {
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
    
    public var segment: Segment
    public var vertex: CGPoint
    
    public init(segment: Segment, vertex: CGPoint) {
        self.segment = segment
        self.vertex = vertex
    }
    
    /// 计算三角形的边界框，包含贝塞尔曲线段和顶点
    public var bounds: CGRect {
        // 收集所有控制点和顶点
        let points = [
            segment.start,
            segment.control1,
            segment.control2,
            segment.end,
            vertex
        ]
        
        // 计算边界框
        if let pointsBounds = points.bounds {
            return pointsBounds
        }
        
        // 如果无法计算边界框（例如，没有点），返回零矩形
        return .zero
    }
    
    /// 判断三角形是否为逆时针方向
    /// 使用曲线的起点、终点和顶点来计算
    public var isCCW: Bool {
        // 创建三角形的顶点数组
        let points = [segment.start, segment.end, vertex]
        
        // 使用 polyIsCCW 方法计算方向
        return points.polyIsCCW
    }
    
    /// 获取方向指示符号
    public var orientationSymbol: String {
        isCCW ? "↺" : "↻"
    }
}
