//
//  SegmentType.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics

public enum SegmentShapeSource {
    public typealias PathBuilder = (_ start: CGPoint, _ end: CGPoint) -> AppBezierPath
    
    case line
    case arrow
    case custom(PathBuilder)
    
    public func getPath(start: CGPoint, end: CGPoint) -> AppBezierPath {
        let path = AppBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }
}
