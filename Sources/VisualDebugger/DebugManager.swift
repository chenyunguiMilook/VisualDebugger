//
//  Debugger.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/22.
//
import Foundation
import CoreGraphics
import VisualUtils

// manager global debug elements
public final class DebugManager: @unchecked Sendable {
    // 单例模式
    public static let shared: DebugManager = .init()

    private let queue = DispatchQueue(label: "logger.queue")
    public private(set) var elements: [any ContextRenderable] = []

    private init() {
        
    }
    
    public func add(_ element: any ContextRenderable) {
        queue.sync {
            self.elements.append(element)
        }
    }
}

extension DebugManager: ContextRenderable {
    public func render(with transform: Matrix2D, in context: CGContext, scale: CGFloat, contextHeight: Int?) {
        for element in elements {
            element.render(with: transform, in: context, scale: scale, contextHeight: contextHeight)
        }
    }
}
