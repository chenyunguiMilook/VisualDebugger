//
//  Polygon.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/28.
//


import CoreGraphics
#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

public struct PolygonShape: ShapeRenderer {
    public var center: CGPoint
    public var radius: Double
    public var edgeCount: Int
    
    public var bounds: CGRect {
        CGRect(center: center, size: .init(width: radius * 2, height: radius * 2))
    }
    
    public init(center: CGPoint = .zero, radius: Double, edgeCount: Int) {
        self.center = center
        self.radius = radius
        self.edgeCount = edgeCount
    }
    
    public init(center: CGPoint = .zero, edgeLength: Double, edgeCount: Int) {
        self.center = center
        self.edgeCount = edgeCount
        
        // 确保边数至少为3（三角形）
        let sides = max(edgeCount, 3)
        
        // 计算内切圆半径
        // 对于正多边形，边长与内切圆半径的关系是：
        // radius = edgeLength / (2 * sin(π/sides))
        let angle = Double.pi / Double(sides)
        self.radius = edgeLength / (2 * sin(angle))
    }

    public func getBezierPath() -> AppBezierPath {
        // 创建一个新的 UIBezierPath
        let path = AppBezierPath()
        
        // 确保边数至少为3（三角形）
        let sides = max(edgeCount, 3)
        
        // 计算每个顶点之间的角度
        let angle = 2.0 * Double.pi / Double(sides)
        
        // 计算初始角度
        let startAngle: Double
        
        if sides % 2 == 1 {
            // 奇数边形：第一个顶点在顶部中心 (270度或-90度，因为Y轴向下为正)
            startAngle = -Double.pi / 2.0
        } else {
            // 偶数边形：第一条边在顶部中心
            // 需要将多边形旋转半个角度，使第一条边水平对齐顶部
            startAngle = -Double.pi / 2.0 - angle / 2.0
        }
        
        // 计算第一个点的坐标并设置为起点
        let firstX = center.x + CGFloat(radius * cos(startAngle))
        let firstY = center.y + CGFloat(radius * sin(startAngle))
        path.move(to: CGPoint(x: firstX, y: firstY))
        
        // 计算并连接所有其他顶点
        for i in 1..<sides {
            let currentAngle = startAngle + Double(i) * angle
            let x = center.x + CGFloat(radius * cos(currentAngle))
            let y = center.y + CGFloat(radius * sin(currentAngle))
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // 闭合路径
        path.close()
        
        return path
    }
}
