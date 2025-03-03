//
//  ShapeRenderElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import Foundation
import CoreGraphics

public struct ShapeRenderElement: Debuggable {
    
    // TODO: 添加一个transform属性， 这样原始路径可以被保存，不需要频繁变换路径，只在渲染的时候计算即可？
    public let path: AppBezierPath
    public let style: ShapeRenderStyle
    
    public init(path: AppBezierPath, style: ShapeRenderStyle) {
        self.path = path
        self.style = style
    }
    
    public var debugBounds: CGRect? {
        self.path.bounds
    }
    
    public func applying(transform: Matrix2D) -> ShapeRenderElement {
        let p: AppBezierPath = (self.path * transform) ?? AppBezierPath()
        return ShapeRenderElement(path: p, style: self.style)
    }

    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        context.render(path: path.cgPath, style: style)
    }
}

public func *(lhs: ShapeRenderElement, rhs: Matrix2D) -> ShapeRenderElement {
    let path = (lhs.path * rhs) ?? AppBezierPath()
    return ShapeRenderElement(path: path, style: lhs.style)
}
