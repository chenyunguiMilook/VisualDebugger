//
//  ArrowRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/27.
//

import CoreGraphics

public struct SegmentRenderElement: ContextRenderable {
    
    public let startPoint: CGPoint
    public let endPoint: CGPoint
    
    public let color: AppColor
    public let lineWidth: CGFloat
    public let endpointsSize: CGFloat

    public let startStyle: EndpointStyle?
    public let endStyle: EndpointStyle?

    private var renderElements: [ContextRenderable] = []
    var hasStart: Bool { startStyle != nil }
    var hasEnd: Bool { endStyle != nil }
    
    public init(
        color: AppColor,
        startPoint: CGPoint,
        endPoint: CGPoint,
        startStyle: EndpointStyle? = nil,
        endStyle: EndpointStyle? = nil,
        lineWidth: CGFloat = 1,
        endpointsSize: CGFloat = 5
    ) {
        self.color = color
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.startStyle = startStyle
        self.endStyle = endStyle
        self.endpointsSize = endpointsSize
        self.lineWidth = lineWidth
        self.renderElements = createRenderElements()
    }
    
    public func render(in context: CGContext, contentScaleFactor: CGFloat, contextHeight: Int?) {
        for element in renderElements {
            element.render(in: context, contentScaleFactor: contentScaleFactor, contextHeight: contextHeight)
        }
    }
    
    private func createRenderElements() -> [ContextRenderable] {
        var elements: [ContextRenderable] = []
        
        var segment = Segment(start: startPoint, end: endPoint)
        // If points are too close, return empty array
        if segment.length < endpointsSize * 2 {
            return elements
        }
        // 如果有尾部箭头，调整起点
        if let startStyle, startStyle.occupiedWidth {
            segment = segment.shrinkingStart(length: endpointsSize)
        }
        // 如果有头部箭头，调整终点
        if let endStyle, endStyle.occupiedWidth {
            segment = segment.shrinkingEnd(length: endpointsSize)
        }
        
        // 只有当线段长度为正时才添加线段
        if segment.length > 1 {
            let linePath = AppBezierPath()
            linePath.move(to: segment.start)
            linePath.addLine(to: segment.end)
            elements.append(ShapeRenderElement(path: linePath, style: .init(stroke: .init(color: color, style: .init(lineWidth: lineWidth)))))
        }
        
        if let startStyle {
            let startElement = startStyle.getRenderElement(size: endpointsSize, color: color, lineWidth: lineWidth)
            let transform = Matrix2D(rotationAngle: segment.angle + .pi) * Matrix2D(translation: startPoint)
            elements.append(startElement.applying(transform: transform))
        }
        
        if let endStyle {
            let endElement = endStyle.getRenderElement(size: endpointsSize, color: color, lineWidth: lineWidth)
            let transform = Matrix2D(rotationAngle: segment.angle) * Matrix2D(translation: endPoint)
            elements.append(endElement.applying(transform: transform))
        }
        
        return elements
    }
}

extension SegmentRenderElement: Transformable {
    public func applying(transform: Matrix2D) -> SegmentRenderElement {
        return SegmentRenderElement(
            color: color,
            startPoint: startPoint * transform,
            endPoint: endPoint * transform,
            startStyle: startStyle,
            endStyle: endStyle,
            lineWidth: lineWidth,
            endpointsSize: endpointsSize
        )
    }
}

public func *(lhs: SegmentRenderElement, rhs: Matrix2D) -> SegmentRenderElement {
    lhs.applying(transform: rhs)
}
