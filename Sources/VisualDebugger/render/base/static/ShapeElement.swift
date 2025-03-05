//
//  ShapeElement.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import Foundation
import CoreGraphics

public final class ShapeElement: StaticRendable {
    
    public var renderer: ShapeRenderer
    public var style: ShapeRenderStyle
    
    public init(renderer: ShapeRenderer, style: ShapeRenderStyle) {
        self.renderer = renderer
        self.style = style
    }
    
    public var contentBounds: CGRect {
        renderer.bounds
    }
    
    public func render(
        with transform: Matrix2D,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    ) {
        let t = Matrix2D(translationX: transform.tx, y: transform.ty)
        context.render(
            path: renderer.getBezierPath().cgPath,
            style: style,
            transform: t
        )
    }
    
    public func clone() -> ShapeElement {
        ShapeElement(renderer: renderer, style: style)
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
        guard let p = cgPath.copy(using: &t) else { return }
        
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
