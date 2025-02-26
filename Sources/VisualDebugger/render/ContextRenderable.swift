//
//  ContextRenderable.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import Foundation
import CoreGraphics

extension Array: Transformable where Element: Transformable {
    public func applying(transform: Matrix2D) -> [Element] {
        self.map { $0.applying(transform: transform) }
    }
}

extension Array: ContextRenderable where Element: ContextRenderable {
    public func render(in context: CGContext, contentScaleFactor: CGFloat, contextHeight: Int?) {
        for element in self {
            element.render(in: context, contentScaleFactor: contentScaleFactor, contextHeight: contextHeight)
        }
    }
}

public protocol ContextRenderElementOwner {
    var renderElement: ContextRenderable { get }
}
