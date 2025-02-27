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
        
        // 箭头样式选项
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
    
    // 存储渲染元素，避免每次渲染时重新计算
    private let renderElements: [ContextRenderable]
    
    public init(
        startPoint: CGPoint,
        endPoint: CGPoint,
        headSize: CGFloat = 10,
        bodyWidth: CGFloat = 1,
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
        
        // 在初始化时创建渲染元素
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
        
        // 计算方向向量
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let length = sqrt(dx * dx + dy * dy)
        
        // 如果点太近，返回空数组
        if length < 0.1 {
            return elements
        }
        
        // 计算旋转角度
        let angle = atan2(dy, dx)
        
        // 创建箭头连线
        let linePath = AppBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        elements.append(ShapeRenderElement(path: linePath, style: lineStyle))
        
        // 处理箭头头部
        if options.contains(.head) {
            let arrowHeadPath = AppBezierPath.xArrow(size: headSize)
            let headElement = MarkRenderElement(
                path: arrowHeadPath,
                style: arrowStyle,
                position: endPoint
            )
            
            // 旋转元素以匹配箭头方向
            let rotatedHeadElement = headElement.applying(
                transform: Matrix2D(rotate: angle, aroundCenter: endPoint)
            )
            elements.append(rotatedHeadElement)
        }
        
        // 处理箭头尾部
        if options.contains(.tail) {
            let arrowTailPath = AppBezierPath.xArrow(size: headSize)
            let tailElement = MarkRenderElement(
                path: arrowTailPath,
                style: arrowStyle,
                position: startPoint
            )
            
            // 旋转元素以匹配反向箭头方向
            let rotatedTailElement = tailElement.applying(
                transform: Matrix2D(rotate: angle + .pi, aroundCenter: startPoint)
            )
            elements.append(rotatedTailElement)
        }
        
        return elements
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
