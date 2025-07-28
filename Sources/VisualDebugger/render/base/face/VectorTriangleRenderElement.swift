//
//  VectorTriangleRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/11.
//

import CoreGraphics
import VisualUtils

public final class VectorTriangleRenderElement: ContextRenderable {
    
    public let triangle: VectorTriangle
    public let transform: Matrix2D
    public let label: TextElement?
    public let style: ShapeRenderStyle
    
    lazy var path: AppBezierPath = {
        let path = AppBezierPath()
        // 从贝塞尔曲线段的起点开始
        path.move(to: triangle.segment.start)
        // 添加贝塞尔曲线
        path.addCurve(to: triangle.segment.end, 
                     controlPoint1: triangle.segment.control1, 
                     controlPoint2: triangle.segment.control2)
        // 连接到顶点
        path.addLine(to: triangle.vertex)
        // 闭合路径
        path.close()
        return path
    }()
    
    lazy var center: CGPoint = {
        // 计算三角形的重心
        let p0 = triangle.segment.start
        let p3 = triangle.segment.end
        let v = triangle.vertex
        return (p0 + p3 + v) / 3.0
    }()
    
    public init(triangle: VectorTriangle, transform: Matrix2D = .identity, style: ShapeRenderStyle, label: TextElement? = nil) {
        self.triangle = triangle
        self.transform = transform
        self.label = label
        self.style = style
    }
    
    public func applying(transform: Matrix2D) -> VectorTriangleRenderElement {
        self * transform
    }
    
    public func render(with matrix: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        let transform = self.transform * matrix
        if let newPath = self.path * transform {
            context.render(path: newPath.cgPath, style: style)
        }
        label?.render(
            with: Matrix2D(translation: center) * matrix,
            in: context,
            scale: scale,
            contextHeight: contextHeight
        )
    }
}

public func *(lhs: VectorTriangleRenderElement, rhs: Matrix2D) -> VectorTriangleRenderElement {
    VectorTriangleRenderElement(
        triangle: lhs.triangle,
        transform: lhs.transform * rhs,
        style: lhs.style,
        label: lhs.label
    )
}
