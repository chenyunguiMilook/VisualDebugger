//
//  Path.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/16.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public typealias VPath = Path

public final class Path {
    
    public enum PathStyle {
        case stroke(width: CGFloat = 1, dashed: Bool = false)
        case fill
    }
    
    public let path: AppBezierPath
    public let element: ShapeRenderElement
    
    public init(
        path: AppBezierPath,
        name: String? = nil,
        color: AppColor = .yellow,
        style: PathStyle =  .stroke()
    ) {
        self.path = path
        let style: ShapeRenderStyle = switch style {
        case .stroke(let width, let dashed):
            .init(stroke: .init(color: color, style: .init(lineWidth: width, dash: dashed ? [5, 5] : [] )))
        case .fill:
            .init(fill: .init(color: color))
        }
        self.element = ShapeRenderElement(path: path, style: style)
    }
}

extension Path: DebugRenderable {
    
    public var debugBounds: CGRect? {
        element.debugBounds
    }
    
    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        element.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
    }
}
