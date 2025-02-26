//
//  ContextRenderable.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import Foundation
import CoreGraphics

public protocol ContextRenderable {
    func render(in context: CGContext)
}

extension Array: ContextRenderable where Element: ContextRenderable {
    
    public func render(in context: CGContext) {
        for element in self {
            element.render(in: context)
        }
    }
}

public protocol ContextRenderElementOwner {
    var renderElement: ContextRenderable { get }
}
