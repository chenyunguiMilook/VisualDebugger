//
//  FaceRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/7.
//

import CoreGraphics

public final class FaceRenderElement: Transformable, ContextRenderable {
    
    public let points: [CGPoint]
    public let transform: Matrix2D
    public let label: TextElement?
    public let style: ShapeRenderStyle
    
    lazy var path: AppBezierPath = {
        let path = AppBezierPath()
        path.move(to: points[0])
        for i in 1 ..< points.count {
            path.addLine(to: points[i])
        }
        path.close()
        return path
    }()
    lazy var center: CGPoint = {
        points.gravityCenter
    }()
    
    public init(points: [CGPoint], transform: Matrix2D = .identity, style: ShapeRenderStyle, label: TextElement? = nil) {
        self.points = points
        self.transform = transform
        self.label = label
        self.style = style
    }
    
    public func applying(transform: Matrix2D) -> FaceRenderElement {
        self * transform
    }
    
    public func render(with matrix: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        guard !points.isEmpty else { return }
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

public func *(lhs: FaceRenderElement, rhs: Matrix2D) -> FaceRenderElement {
    FaceRenderElement(
        points: lhs.points,
        transform: lhs.transform * rhs,
        style: lhs.style,
        label: lhs.label
    )
}
