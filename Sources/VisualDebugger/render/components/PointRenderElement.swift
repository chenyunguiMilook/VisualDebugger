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
    case shape(shape: VertexShape, color: AppColor, name: NameStyle? = nil, radius: Double = .pointRadius)
    case label(LabelStyle, color: AppColor, name: NameStyle? = nil)
}

extension PointStyle {
    var occupiedWidth: Double {
        switch self {
        case .shape(_, _, _, let radius):
            return radius
        case .label:
            return 6
        }
    }
    
    public var color: AppColor {
        switch self {
        case .shape(_, let color, _, _):
            return color
        case .label(_, let color, _):
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
        case .shape(let shape, let color, let name, let radius):
            let path = shape.getPath(radius: radius)
            let style = getStyle(color: color, filled: shape.isFilled)
            let shape = StaticRenderElement<ShapeElement>(path: path, style: style, position: center, rotatable: false)
            var elements: [ContextRenderable] = [shape]
            if let name {
                elements.append(NameRenderElement(name: name, style: .nameLabel, position: center))
            }
            return elements
        case .label(let label, let color, let name):
            var style = TextRenderStyle.indexLabel
            style.textColor = label.filled ? .white : color
            style.bgStyle = .capsule(color: color, filled: label.filled)
            var elements: [ContextRenderable] = [LabelRenderElement(label: label, style: style, position: center)]
            if let name {
                elements.append(NameRenderElement(name: name, style: .nameLabel, position: center))
            }
            return elements
        }
    }
}
