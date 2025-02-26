//
//  DebugPoints.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//


import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class DebugPoints {
    
    public enum Style {
        case dot(color: AppColor, radius: Double)
        case circle(color: AppColor, radius: Double)
        case cross(color: AppColor, size: Double)
        case index(style: TextRenderStyle)
        // TODO: support label, polygon, polyShape, highlight(index), transform(Matrix) etc...
    }
    
    public let points: [CGPoint]
    
    // additional style
    private var _styles: [Style] = []
    public var styles: [Style] {
        [baseStyle] + _styles
    }

    public var baseStyle: Style
    
    public init(points: [CGPoint], style: Style = .dot(color: .yellow, radius: 2), styles: [Style] = []) {
        self.points = points
        self.baseStyle = style
        self._styles = styles
    }
    
    public func addStyle(_ style: Style) -> Self {
        _styles.append(style)
        return self
    }
}

extension DebugPoints: Debuggable {
    public var debugBounds: CGRect? {
        return points.bounds
    }
    
    public func applying(transform: Matrix2D) -> DebugPoints {
        DebugPoints(points: points * transform, style: baseStyle, styles: _styles)
    }
    
    public func render(in context: CGContext, contentScaleFactor: CGFloat, contextHeight: Int?) {
        for style in styles {
            let elements = style.getRenderElements(points: points)
            for element in elements {
                element.render(in: context, contentScaleFactor: contentScaleFactor, contextHeight: contextHeight)
            }
        }
    }
}

extension DebugPoints.Style {
    
    func getRenderElements(points: [CGPoint]) -> [ContextRenderable] {
        switch self {
        case .dot(color: let color, radius: let radius):
            let path = AppBezierPath.dot(radius: radius)
            let style = ShapeRenderStyle(fill: .init(color: color))
            return points.map { point in
                MarkRenderElement(path: path, style: style, position: point)
            }
        case .circle(color: let color, radius: let radius):
            let path = AppBezierPath.dot(radius: radius)
            let style = ShapeRenderStyle(stroke: .init(color: color, style: .init(lineWidth: 1)))
            return points.map { point in
                MarkRenderElement(path: path, style: style, position: point)
            }
        case .cross(color: let color, size: let size):
            let path = AppBezierPath.cross(size: size)
            let style = ShapeRenderStyle(stroke: .init(color: color, style: .init(lineWidth: 1)))
            return points.map { point in
                MarkRenderElement(path: path, style: style, position: point)
            }
        case .index(style: let style):
            return points.enumerated().map { i, point in
                TextRenderElement(text: "\(i)", style: style, position: point)
            }
        }
    }
}

extension AppBezierPath {
    
    public static func dot(radius: Double) -> AppBezierPath {
        AppBezierPath(ovalIn: .init(center: .zero, size: .init(width: radius * 2, height: radius * 2)))
    }
    
    public static func cross(size: Double) -> AppBezierPath {
        let path = AppBezierPath()
        path.move(to: .init(x: -size, y: -size))
        path.addLine(to: .init(x: size, y: size))
        path.move(to: .init(x: size, y: -size))
        path.addLine(to: .init(x: -size, y: size))
        return path
    }
}
