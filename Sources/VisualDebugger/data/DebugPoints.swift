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
        // TODO: support label, polygon, polyShape etc...
    }
    
    public let points: [CGPoint]
    
    // additional style
    private var _styles: [Style] = []
    public var styles: [Style] {
        [baseStyle] + _styles
    }

    public var baseStyle: Style
    
    public init(points: [CGPoint], baseStyle: Style = .dot(color: .yellow, radius: 2), styles: [Style] = []) {
        self.points = points
        self.baseStyle = baseStyle
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
        DebugPoints(points: points * transform, styles: _styles)
    }
    
    public func render(in context: CGContext, contentScaleFactor: CGFloat, contextHeight: Int?) {
        for style in styles {
            let path = style.path
            let s = style.style
            for point in points {
                if let p = path * Matrix2D(translation: point) {
                    context.render(path: p.cgPath, style: s)
                }
            }
        }
    }
}

extension DebugPoints.Style {
    public var path: AppBezierPath {
        switch self {
        case .dot(color: _, radius: let radius): fallthrough
        case .circle(color: _, radius: let radius):
            return AppBezierPath.dot(radius: radius)
        case .cross(color: _, size: let size):
            return AppBezierPath.cross(size: size)
        }
    }
    
    public var style: ShapeRenderStyle {
        switch self {
        case .dot(color: let color, radius: _):
            return ShapeRenderStyle(fill: .init(color: color))
        case .circle(color: let color, radius: _):
            return ShapeRenderStyle(stroke: .init(color: color, style: .init(lineWidth: 1)))
        case .cross(color: let color, size: _):
            return ShapeRenderStyle(stroke: .init(color: color, style: .init(lineWidth: 1)))
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
