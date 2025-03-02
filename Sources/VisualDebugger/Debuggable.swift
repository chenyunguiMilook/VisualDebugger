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
    func render(in context: CGContext, scale: CGFloat, contextHeight: Int?)
}

public protocol Debuggable: ContextRenderable {
    var debugBounds: CGRect? { get }
}

extension Array where Element == any Debuggable {
    
    public var debugBounds: CGRect? {
        self.compactMap { $0.debugBounds }.bounds
    }
    
    public func render(in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        for element in self {
            element.render(in: context, scale: scale, contextHeight: contextHeight)
        }
    }
}
