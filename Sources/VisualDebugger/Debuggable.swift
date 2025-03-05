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

public protocol DebugRenderable: ContextRenderable {
    var debugBounds: CGRect? { get }
}

public protocol Debuggable {
    var debugElements: [any DebugRenderable] { get }
}

extension Debuggable {
    @MainActor
    public var debugView: DebugView {
        DebugView(elements: debugElements)
    }
    
    public func debugContext(
        minWidth: Double = 250,
        numSegments: Int = 5,
        showOrigin: Bool = false,
        showCoordinate: Bool = true,
        coordinateSystem: CoordinateSystem2D = .yDown,
        coordinateStyle: CoordinateStyle = .default
    ) -> DebugContext {
        DebugContext(
            minWidth: minWidth,
            numSegments: numSegments,
            showOrigin: showOrigin,
            showCoordinate: showCoordinate,
            coordinateSystem: coordinateSystem,
            coordinateStyle: coordinateStyle,
            elements: debugElements
        )
    }
}

extension Array: Transformable where Element == any Transformable {
    public func applying(transform: Matrix2D) -> [Element] {
        self.map { $0.applying(transform: transform) }
    }
}

extension Array: ContextRenderable where Element == any DebugRenderable {
    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        for element in self {
            element.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
        }
    }
}

extension Array: DebugRenderable where Element == any DebugRenderable {
    public var debugBounds: CGRect? {
        self.compactMap { $0.debugBounds }.bounds
    }
}
