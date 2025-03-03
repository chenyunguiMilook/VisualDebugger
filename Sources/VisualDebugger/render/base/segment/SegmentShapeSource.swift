//
//  SegmentType.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics

public enum ArrowStyle {
    case line // current implementation
    case triangle // draw a triangle and an line
    case topTriangle // top part of the triangle
    case bottomTriangle // bottom part of the triangle
}

public enum ArrowDirection {
    case normal
    case reverse
    case double // double headed
}

public enum SegmentShapeSource {
    public typealias PathBuilder = (_ start: CGPoint, _ end: CGPoint) -> AppBezierPath
    
    case line
    case arrow(style: ArrowStyle, direction: ArrowDirection)
    case custom(PathBuilder)
    
    public func getPath(start: CGPoint, end: CGPoint) -> AppBezierPath {
        switch self {
        case .line:
            // 简单的线段路径
            let path = AppBezierPath()
            path.move(to: start)
            path.addLine(to: end)
            return path
            
        case .arrow(let style, let direction):
            let path = AppBezierPath()
            let segment = Segment(start: start, end: end)
            let arrowLength = min(12.0, segment.length * 0.3)  // 箭头长度，不超过线段长度的30%
            
            // 创建调整后的线段
            var mainSegment = segment
            if style == .triangle {
                // 根据箭头方向调整线段
                if direction == .normal || direction == .double {
                    mainSegment = mainSegment.shrinkingEnd(length: arrowLength)
                }
                if direction == .reverse || direction == .double {
                    mainSegment = mainSegment.shrinkingStart(length: arrowLength)
                }
            }
            
            // 绘制主线段
            path.move(to: mainSegment.start)
            path.addLine(to: mainSegment.end)
            
            // 添加箭头
            if direction == .normal || direction == .double {
                let angle = segment.angle
                let endTransform = Matrix2D(rotationAngle: angle) * Matrix2D(translation: end)
                addArrowHead(to: path, transform: endTransform, style: style, arrowLength: arrowLength)
            }
            
            if direction == .reverse || direction == .double {
                let angle = segment.angle
                let startTransform = Matrix2D(rotationAngle: angle + .pi) * Matrix2D(translation: start)
                addArrowHead(to: path, transform: startTransform, style: style, arrowLength: arrowLength)
            }
            
            return path
            
        case .custom(let pathBuilder):
            // 使用自定义路径构建器
            return pathBuilder(start, end)
        }
    }
    
    // 辅助方法：使用变换矩阵添加箭头头部
    private func addArrowHead(to path: AppBezierPath, transform: Matrix2D, style: ArrowStyle, arrowLength: CGFloat) {
        let arrowAngle: CGFloat = CGFloat.pi / 8  // 30度
        let width = arrowLength
        let height = 2 * arrowLength * sin(arrowAngle)
        
        switch style {
        case .line:
            // 创建基础箭头路径（在原点）
            let arrowPath = AppBezierPath()
            arrowPath.move(to: .zero)
            arrowPath.addLine(to: CGPoint(x: -width, y: -height/2))
            arrowPath.move(to: .zero)
            arrowPath.addLine(to: CGPoint(x: -width, y: height/2))
            
            // 应用变换并添加到主路径
            if let transformedPath = arrowPath * transform {
                path.append(transformedPath)
            }
            
        case .triangle:
            // 使用Triangle结构体创建箭头
            let triangle = Triangle(width: width, height: height)
            let transformedTriangle = triangle * transform
            path.append(transformedTriangle.getPath())
            
        case .topTriangle:
            // 使用Triangle结构体创建上半部分三角形
            let triangle = Triangle(width: width, height: height)
            let transformedTriangle = triangle * transform
            path.append(transformedTriangle.getTopHalfPath())
            
        case .bottomTriangle:
            // 使用Triangle结构体创建下半部分三角形
            let triangle = Triangle(width: width, height: height)
            let transformedTriangle = triangle * transform
            path.append(transformedTriangle.getBottomHalfPath())
        }
    }
}


struct Triangle {
    var tip: CGPoint
    var topLeft: CGPoint
    var bottomLeft: CGPoint
    
    var middleLeft: CGPoint {
        (topLeft + bottomLeft) / 2.0
    }
    
    init(width: Double, height: Double) {
        self.tip = .zero
        self.topLeft = .init(x: -width, y: -height/2)
        self.bottomLeft = .init(x: -width, y: height/2)
    }
    
    init(tip: CGPoint, topLeft: CGPoint, bottomLeft: CGPoint) {
        self.tip = tip
        self.topLeft = topLeft
        self.bottomLeft = bottomLeft
    }
    
    func getPath() -> AppBezierPath {
        let path = AppBezierPath()
        path.move(to: tip)
        path.addLine(to: topLeft)
        path.addLine(to: bottomLeft)
        path.close()
        return path
    }
    
    func getTopHalfPath() -> AppBezierPath {
        let path = AppBezierPath()
        path.move(to: tip)
        path.addLine(to: topLeft)
        path.addLine(to: middleLeft)
        path.close()
        return path
    }
    
    func getBottomHalfPath() -> AppBezierPath {
        let path = AppBezierPath()
        path.move(to: tip)
        path.addLine(to: middleLeft)
        path.addLine(to: bottomLeft)
        path.close()
        return path
    }
}

func *(lhs: Triangle, rhs: Matrix2D) -> Triangle {
    Triangle(
        tip: lhs.tip * rhs,
        topLeft: lhs.topLeft * rhs,
        bottomLeft: lhs.bottomLeft * rhs
    )
}
