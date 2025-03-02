//
//  ShapeElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import Foundation
import CoreGraphics

public struct ShapeElement: StaticRendable {
    
    public let path: AppBezierPath
    public let style: ShapeRenderStyle
    
    public init(path: AppBezierPath, style: ShapeRenderStyle) {
        self.path = path
        self.style = style
    }
    
    public func render(
        to location: CGPoint,
        angle: Double,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    ) {
        let r = Matrix2D(rotationAngle: angle)
        let t = Matrix2D(translation: location)
        context.render(path: path.cgPath, style: style, transform: r * t)
    }
}

extension CGContext {
    
    public func render(
        path cgPath: CGPath,
        style: ShapeRenderStyle,
        transform: Matrix2D
    ) {
        guard !cgPath.isEmpty, !style.isEmpty else { return }
        var t = transform
        guard let p = path?.copy(using: &t) else { return }
        
        self.saveGState()
        defer { self.restoreGState() }
        // fill
        if let fill = style.fill {
            self.addPath(p)
            fill.set(for: self)
            self.fillPath(using: fill.rule)
        }
        
        // stroke
        if let stroke = style.stroke {
            self.addPath(p)
            stroke.set(for: self)
            self.strokePath()
        }
    }
}
