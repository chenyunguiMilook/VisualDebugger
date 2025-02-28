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
    static let pointRadius: Double = 2
}
extension Bool {
    @usableFromInline
    static let shapeFilled = true
    @usableFromInline
    static let labelFilled = false
}

public struct PointRenderElement: ContextRenderable {
    
    public let style: PointStyle
    public var center: CGPoint
    
    public init(style: PointStyle, center: CGPoint) {
        self.style = style
        self.center = center
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        for element in style.getRenderElements(center: center) {
            element.render(in: context, scale: scale, contextHeight: contextHeight)
        }
    }
    
    public func applying(transform: Matrix2D) -> PointRenderElement {
        PointRenderElement(style: style, center: center * transform)
    }
}

public enum PointStyle {
    public enum Shape {
        case rect, circle, triangle
    }
    case shape(shape: Shape, color: AppColor, name: String? = nil, radius: Double = .pointRadius, filled: Bool = .shapeFilled)
    case label(String, color: AppColor, name: String? = nil, filled: Bool = .labelFilled)
}

extension PointStyle.Shape {
    public func getPath(radius: Double) -> AppBezierPath {
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
    var occupiedWidth: Double {
        switch self {
        case .shape(_, _, _, let radius, _):
            return radius
        case .label:
            return 6
        }
    }
        
    public var color: AppColor {
        switch self {
        case .shape(_, let color, _, _, _):
            return color
        case .label(_, let color, _, _):
            return color
        }
    }
    public func getRenderElements(center: CGPoint) -> [ContextRenderable] {
        func getStyle(color: AppColor, filled: Bool) -> ShapeRenderStyle {
            if filled {
                ShapeRenderStyle(fill: .init(color: color))
            } else {
                ShapeRenderStyle(stroke: .init(color: color, style: .init(lineWidth: 1)))
            }
        }
        switch self {
        case .shape(let shape, let color, let name, let radius, let filled):
            let path = shape.getPath(radius: radius)
            let style = getStyle(color: color, filled: filled)
            let shape = MarkRenderElement(path: path, style: style, position: center, rotatable: false)
            var elements: [ContextRenderable] = [shape]
            if let name {
                elements.append(TextRenderElement(text: name, style: .nameLabel, position: center))
            }
            return elements
        case .label(let string, let color, let name, let filled):
            var style = TextRenderStyle.indexLabel
            style.textColor = filled ? .white : color
            style.bgStyle = .capsule(color: color, filled: filled)
            var elements = [TextRenderElement(text: string, style: style, position: center)]
            if let name {
                elements.append(TextRenderElement(text: name, style: .nameLabel, position: center))
            }
            return elements
        }
    }
}
