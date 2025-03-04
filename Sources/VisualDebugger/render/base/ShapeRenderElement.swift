//
//  ShapeRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import Foundation
import CoreGraphics

public struct ShapeRenderElement: Transformable, Debuggable {
    
    // TODO: 添加一个transform属性， 这样原始路径可以被保存，不需要频繁变换路径，只在渲染的时候计算即可？
    public let path: AppBezierPath
    public let transform: Matrix2D
    public let style: ShapeRenderStyle
    
    public init(path: AppBezierPath, transform: Matrix2D = .identity, style: ShapeRenderStyle) {
        self.path = path
        self.transform = transform
        self.style = style
    }
    
    public var debugBounds: CGRect? {
        self.path.bounds * self.transform
    }
    
    public func applying(transform: Matrix2D) -> ShapeRenderElement {
        return ShapeRenderElement(path: self.path, transform: self.transform * transform, style: self.style)
    }

    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        guard let p = path * (self.transform * transform) else { return }
        context.render(path: p.cgPath, style: style)
    }
}

public func *(lhs: ShapeRenderElement, rhs: Matrix2D) -> ShapeRenderElement {
    let path = (lhs.path * rhs) ?? AppBezierPath()
    return ShapeRenderElement(path: path, style: lhs.style)
}
