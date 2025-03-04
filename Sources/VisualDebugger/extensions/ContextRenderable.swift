//
//  ContextRenderable.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import Foundation
import CoreGraphics


public protocol ContextRenderElementOwner {
    var renderElement: ContextRenderable { get }
}
