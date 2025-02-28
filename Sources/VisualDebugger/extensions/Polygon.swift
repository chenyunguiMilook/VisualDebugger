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

struct Polygon {
    var center: CGPoint
    var radius: Double
    var edgeCount: Int
    
    init(center: CGPoint, radius: Double, edgeCount: Int) {
        self.center = center
        self.radius = radius
        self.edgeCount = edgeCount
    }
    
    func getBezierPath() -> AppBezierPath {
        // 创建一个新的 UIBezierPath
        let path = AppBezierPath()
        
        // 确保边数至少为3（三角形）
        let sides = max(edgeCount, 3)
        
        // 计算每个顶点之间的角度
        let angle = 2.0 * Double.pi / Double(sides)
        
        // 计算第一个点的坐标并设置为起点
        let firstX = center.x + CGFloat(radius * cos(0.0))
        let firstY = center.y + CGFloat(radius * sin(0.0))
        path.move(to: CGPoint(x: firstX, y: firstY))
        
        // 计算并连接所有其他顶点
        for i in 1..<sides {
            let currentAngle = Double(i) * angle
            let x = center.x + CGFloat(radius * cos(currentAngle))
            let y = center.y + CGFloat(radius * sin(currentAngle))
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // 闭合路径
        path.close()
        
        return path
    }
}
