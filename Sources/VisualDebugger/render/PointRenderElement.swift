//
//  PointRenderElement.swift
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

extension Double {
    @usableFromInline
    static let radius: Double = 2
}
extension Bool {
    @usableFromInline
    static let filled: Bool = true
}

public struct PointRenderElement: ContextRenderable {
    
    public let style: PointStyle
    public var center: CGPoint
    
    public init(style: PointStyle, center: CGPoint) {
        self.style = style
        self.center = center
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        style.getRenderElement(center: center)
            .render(in: context, scale: scale, contextHeight: contextHeight)
    }
    
    public func applying(transform: Matrix2D) -> PointRenderElement {
        PointRenderElement(style: style, center: center * transform)
    }
}

public enum PointStyle {
    public enum Shape {
        case rect, circle, triangle
    }
    case shape(shape: Shape, color: AppColor, radius: Double = .radius, filled: Bool = .filled)
    case label(String, color: AppColor, filled: Bool = .filled)
}

extension PointStyle.Shape {
    func getPath(radius: Double) -> AppBezierPath {
        let rect = CGRect(center: .zero, size: .init(width: radius * 2, height: radius * 2))
        switch self {
        case .rect:
            return AppBezierPath(rect: rect)
        case .circle:
            return AppBezierPath(ovalIn: rect)
        case .triangle:
            return Polygon(center: .zero, radius: radius, edgeCount: 3).getBezierPath()
        }
    }
}

extension PointStyle {
    
    func getRenderElement(center: CGPoint) -> ContextRenderable {
        func getStyle(color: AppColor, filled: Bool) -> ShapeRenderStyle {
            if filled {
                ShapeRenderStyle(fill: .init(color: color))
            } else {
                ShapeRenderStyle(stroke: .init(color: color, style: .init(lineWidth: 1)))
            }
        }
        switch self {
        case .shape(let shape, let color, let radius, let filled):
            let path = shape.getPath(radius: radius)
            let style = getStyle(color: color, filled: filled)
            return MarkRenderElement(path: path, style: style, position: center, rotatable: false)
        case .label(let string, let color, let filled):
            var style = TextRenderStyle.indexLabel
            style.bgStyle = .capsule(color: color, filled: filled)
            return TextRenderElement(text: string, style: style, position: center)
        }
    }
}
