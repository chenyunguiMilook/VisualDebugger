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

public protocol ContextRenderable {
    func render(
        with transform: Matrix2D,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    )
}

public protocol Debuggable: ContextRenderable {
    var debugBounds: CGRect? { get }
}

extension Array: Transformable where Element == any Transformable {
    public func applying(transform: Matrix2D) -> [Element] {
        self.map { $0.applying(transform: transform) }
    }
}

extension Array: ContextRenderable where Element == any Debuggable {
    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        for element in self {
            element.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
        }
    }
}

extension Array: Debuggable where Element == any Debuggable {
    public var debugBounds: CGRect? {
        self.compactMap { $0.debugBounds }.bounds
    }
}
