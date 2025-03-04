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
    case arrow(Arrow)
    case custom(PathBuilder)
    
    public func getPath(start: CGPoint, end: CGPoint) -> AppBezierPath {
        switch self {
        case .line:
            // 简单的线段路径
            let path = AppBezierPath()
            path.move(to: start)
            path.addLine(to: end)
            return path
            
        case .arrow(let arrow):
            return arrow.getBezierPath(start: start, end: end)
            
        case .custom(let pathBuilder):
            // 使用自定义路径构建器
            return pathBuilder(start, end)
        }
    }
}



