//
//  Debuggable.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import CoreGraphics

public protocol Transformable {
    func applying(transform: Matrix2D) -> Self
}

public protocol ContextRenderable: Transformable {
    func render(in context: CGContext, contentScaleFactor: CGFloat, contextHeight: Int?)
}

public protocol Debuggable: ContextRenderable {
    var debugBounds: CGRect? { get }
}

extension Array where Element == any Debuggable {
    
    public var debugBounds: CGRect? {
        self.compactMap { $0.debugBounds }.bounds
    }
    
    public func render(in context: CGContext, contentScaleFactor: CGFloat, contextHeight: Int?) {
        for element in self {
            element.render(in: context, contentScaleFactor: contentScaleFactor, contextHeight: contextHeight)
        }
    }
}

extension ShapeRenderElement: Debuggable {
    public var debugBounds: CGRect? {
        self.path.bounds
    }
    
    public func applying(transform: Matrix2D) -> ShapeRenderElement {
        let p: AppBezierPath = (self.path * transform) ?? AppBezierPath()
        return ShapeRenderElement(path: p, style: self.style)
    }
}

extension TextRenderElement: Debuggable {
    public var debugBounds: CGRect? {
        let size = self.style.getTextSize(text: self.text)
        return CGRect(anchor: style.anchor, center: position, size: size)
    }
    
    public func applying(transform: Matrix2D) -> TextRenderElement {
        self * transform
    }
}

extension NumberRenderElement: Debuggable {
    public var debugBounds: CGRect? {
        self.bounds
    }
    
    public func applying(transform: Matrix2D) -> NumberRenderElement {
        self * transform
    }
}

extension MarkRenderElement: Debuggable {
    public var debugBounds: CGRect? {
        CGRect(center: position, size: CGSize(width: 4, height: 4))
    }
    
    public func applying(transform: Matrix2D) -> MarkRenderElement {
        self * transform
    }
}
