//
//  ArrowRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/27.
//

import CoreGraphics

public struct ArrowRenderElement: ContextRenderable {
    
    public struct ArrowOptions: OptionSet, Sendable {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let head = ArrowOptions(rawValue: 1 << 0)
        public static let tail = ArrowOptions(rawValue: 1 << 1)
    }
    
    public let lineStyle: ShapeRenderStyle
    public let arrowStyle: ShapeRenderStyle
    public let options: ArrowOptions
    public let startPoint: CGPoint
    public let endPoint: CGPoint
    public let headSize: CGFloat
    public let bodyWidth: CGFloat
    
    private let renderElements: [ContextRenderable]
    
    public init(
        startPoint: CGPoint,
        endPoint: CGPoint,
        headSize: CGFloat,
        bodyWidth: CGFloat,
        lineStyle: ShapeRenderStyle,
        arrowStyle: ShapeRenderStyle,
        options: ArrowOptions = .head
    ) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.headSize = headSize
        self.bodyWidth = bodyWidth
        self.lineStyle = lineStyle
        self.arrowStyle = arrowStyle
        self.options = options
        
        self.renderElements = ArrowRenderElement.createRenderElements(
            startPoint: startPoint,
            endPoint: endPoint,
            headSize: headSize,
            bodyWidth: bodyWidth,
            lineStyle: lineStyle,
            arrowStyle: arrowStyle,
            options: options
        )
    }
    
    public func render(in context: CGContext, contentScaleFactor: CGFloat, contextHeight: Int?) {
        for element in renderElements {
            element.render(in: context, contentScaleFactor: contentScaleFactor, contextHeight: contextHeight)
        }
    }
    
    private static func createRenderElements(
        startPoint: CGPoint,
        endPoint: CGPoint,
        headSize: CGFloat,
        bodyWidth: CGFloat,
        lineStyle: ShapeRenderStyle,
        arrowStyle: ShapeRenderStyle,
        options: ArrowOptions
    ) -> [ContextRenderable] {
        var elements: [ContextRenderable] = []
        
        // Calculate direction vector
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let length = sqrt(dx * dx + dy * dy)
        
        // If points are too close, return empty array
        if length < 0.1 {
            return elements
        }
        
        // Calculate rotation angle
        let angle = atan2(dy, dx)
        
        // 计算箭头头部和尾部的长度影响
        let unitX = dx / length
        let unitY = dy / length
        
        // 创建箭头线段，但要避免与箭头头部和尾部重叠
        let linePath = AppBezierPath()
        var lineStart = startPoint
        var lineEnd = endPoint
        
        // 如果有尾部箭头，调整起点
        if options.contains(.tail) {
            lineStart = CGPoint(
                x: startPoint.x + unitX * headSize,
                y: startPoint.y + unitY * headSize
            )
        }
        
        // 如果有头部箭头，调整终点
        if options.contains(.head) {
            lineEnd = CGPoint(
                x: endPoint.x - unitX * headSize,
                y: endPoint.y - unitY * headSize
            )
        }
        
        // 只有当线段长度为正时才添加线段
        if sqrt(pow(lineEnd.x - lineStart.x, 2) + pow(lineEnd.y - lineStart.y, 2)) > 0.1 {
            linePath.move(to: lineStart)
            linePath.addLine(to: lineEnd)
            elements.append(ShapeRenderElement(path: linePath, style: lineStyle))
        }
        
        // Add head arrow - now the arrow tip will be exactly at the endpoint
        if options.contains(.head) {
            let arrowHeadPath = xArrowPath(size: headSize)
            let rotatedHeadPath = (arrowHeadPath * Matrix2D(rotationAngle: angle)) ?? AppBezierPath()
            let headElement = MarkRenderElement(
                path: rotatedHeadPath,
                style: arrowStyle,
                position: endPoint,
                rotatable: true
            )
            elements.append(headElement)
        }
        
        // Add tail arrow - now the arrow tip will be exactly at the startpoint
        if options.contains(.tail) {
            let arrowTailPath = xArrowPath(size: headSize)
            // Rotate by 180 degrees to point in opposite direction
            let tailAngle = angle + .pi
            let rotatedTailPath = (arrowTailPath * Matrix2D(rotationAngle: tailAngle)) ?? AppBezierPath()
            let tailElement = MarkRenderElement(
                path: rotatedTailPath,
                style: arrowStyle,
                position: startPoint,
                rotatable: true
            )
            elements.append(tailElement)
        }
        
        return elements
    }
    
    private static func xArrowPath(size: Double) -> AppBezierPath {
        let half = size / 2
        let path = AppBezierPath()
        path.move(to: .zero)
        path.addLine(to: .init(x: -size, y: -half))
        path.addLine(to: .init(x: -size, y: half))
        path.close()
        return path
    }

}

extension ArrowRenderElement: Transformable {
    public func applying(transform: Matrix2D) -> ArrowRenderElement {
        return ArrowRenderElement(
            startPoint: startPoint * transform,
            endPoint: endPoint * transform,
            headSize: headSize,
            bodyWidth: bodyWidth,
            lineStyle: lineStyle,
            arrowStyle: arrowStyle,
            options: options
        )
    }
}

public func *(lhs: ArrowRenderElement, rhs: Matrix2D) -> ArrowRenderElement {
    lhs.applying(transform: rhs)
}
