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
    public let dash: Bool
    public let lineWidth: CGFloat
    public let endpointsSize: CGFloat

    public let startStyle: EndpointStyle?
    public let endStyle: EndpointStyle?
    public let name: NameStyle?

    var hasStart: Bool { startStyle != nil }
    var hasEnd: Bool { endStyle != nil }
    
    public init(
        color: AppColor,
        startPoint: CGPoint,
        endPoint: CGPoint,
        startStyle: EndpointStyle? = nil,
        endStyle: EndpointStyle? = nil,
        name: NameStyle? = nil,
        dash: Bool = false,
        lineWidth: CGFloat = 1,
        endpointsSize: CGFloat = 5
    ) {
        self.color = color
        self.dash = dash
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.startStyle = startStyle
        self.endStyle = endStyle
        self.name = name
        self.endpointsSize = endpointsSize
        self.lineWidth = lineWidth
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        let elements = self.createRenderElements()
        for element in elements {
            element.render(in: context, scale: scale, contextHeight: contextHeight)
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
            let dashArray: [CGFloat] = dash ? [5, 5] : []
            elements.append(
                ShapeRenderElement(
                    path: linePath,
                    style: .init(stroke: .init(color: color, style: .init(lineWidth: lineWidth, dash: dashArray)))
                )
            )
        }
        
        if let startStyle {
            let startElement = startStyle.getRenderElement(size: endpointsSize, color: color, lineWidth: lineWidth)
            let transform = Matrix2D(rotationAngle: segment.angle + .pi) * Matrix2D(translation: startPoint)
            elements.append(startElement.applying(transform: transform))
        }
        
        if let endStyle {
            let endElement = endStyle.getRenderElement(size: endpointsSize, color: color, lineWidth: lineWidth)
            let transform = Matrix2D(rotationAngle: segment.angle) * Matrix2D(translation: endPoint)
            let transformed = endElement.applying(transform: transform)
            elements.append(transformed)
        }
        
        if let name {
            let text = NameRenderElement(name: name, style: .edgeNameLabel, position: segment.center)
            elements.append(text)
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
            name: name,
            dash: dash,
            lineWidth: lineWidth,
            endpointsSize: endpointsSize
        )
    }
}

public func *(lhs: SegmentRenderElement, rhs: Matrix2D) -> SegmentRenderElement {
    lhs.applying(transform: rhs)
}
