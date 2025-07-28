//
//  Debuggable.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import CoreGraphics
import VisualUtils

public protocol ContextRenderable {
    var logs: [Logger.Log] { get }
    func render(
        with transform: Matrix2D,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    )
}

extension ContextRenderable {
    public var logs: [Logger.Log] { [] }
}

public protocol DebugRenderable: ContextRenderable {
    var debugBounds: CGRect? { get }
}

public protocol Debuggable {
    var preferredDebugConfig: DebugContext.Config? { get }
    var debugElements: [any DebugRenderable] { get }
}

extension Debuggable {
    public var preferredDebugConfig: DebugContext.Config? {
        nil
    }
    
    @MainActor
    public var debugView: DebugView {
        DebugView(elements: debugElements)
    }
    
    public func debugContext(
        config: DebugContext.Config = .init()
    ) -> DebugContext {
        DebugContext(
            config: preferredDebugConfig ?? config,
            elements: debugElements
        )
    }
}

extension Array where Element == any DebugRenderable {
    var debugBounds: CGRect? {
        self.compactMap { $0.debugBounds }.bounds
    }
}
