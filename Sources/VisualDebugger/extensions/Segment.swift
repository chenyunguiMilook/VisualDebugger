//
//  Segment.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/27.
//

import CoreGraphics

public struct Segment {
    public var start: CGPoint
    public var end: CGPoint
    
    public init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }
    
    // 计算从 start 到 end 的向量
    private var vector: CGPoint {
        return CGPoint(x: end.x - start.x, y: end.y - start.y)
    }
    
    // 计算线段长度
    public var length: Double {
        let v = vector
        return sqrt(v.x * v.x + v.y * v.y)
    }
    
    public var angle: Double {
        vector.angle
    }
    
    // 返回单位向量
    private func unitVector() -> CGPoint {
        let L = length
        return L > 0 ? CGPoint(x: vector.x / L, y: vector.y / L) : .zero
    }
    
    // 辅助方法：沿指定向量移动点
    private func movePoint(_ point: CGPoint, by distance: Double, along vector: CGPoint) -> CGPoint {
        var newPoint = point
        newPoint.x += distance * vector.x
        newPoint.y += distance * vector.y
        return newPoint
    }
    
    // 从两端收缩线段
    public func shrinking(length: Double) -> Segment {
        if length <= 0 || self.length == 0 { return self }
        let d = min(length, self.length / 2)
        let uv = unitVector()
        let newStart = movePoint(start, by: d, along: uv)
        let newEnd = movePoint(end, by: -d, along: uv)
        return Segment(start: newStart, end: newEnd)
    }
    
    // 从起点收缩线段
    public func shrinkingStart(length: Double) -> Segment {
        if length <= 0 || self.length == 0 { return self }
        let d = min(length, self.length)
        let uv = unitVector()
        let newStart = movePoint(start, by: d, along: uv)
        return Segment(start: newStart, end: end)
    }
    
    // 从终点收缩线段
    public func shrinkingEnd(length: Double) -> Segment {
        if length <= 0 || self.length == 0 { return self }
        let d = min(length, self.length)
        let uv = unitVector()
        let newEnd = movePoint(end, by: -d, along: uv)
        return Segment(start: start, end: newEnd)
    }
    
    // 向两端扩展线段
    public func expanding(length: Double) -> Segment {
        if length <= 0 { return self }
        let uv = unitVector()
        let newStart = movePoint(start, by: -length, along: uv)
        let newEnd = movePoint(end, by: length, along: uv)
        return Segment(start: newStart, end: newEnd)
    }
    
    // 从起点扩展线段
    public func expandingStart(length: Double) -> Segment {
        if length <= 0 { return self }
        let uv = unitVector()
        let newStart = movePoint(start, by: -length, along: uv)
        return Segment(start: newStart, end: end)
    }
    
    // 从终点扩展线段
    public func expandingEnd(length: Double) -> Segment {
        if length <= 0 { return self }
        let uv = unitVector()
        let newEnd = movePoint(end, by: length, along: uv)
        return Segment(start: start, end: newEnd)
    }
}
