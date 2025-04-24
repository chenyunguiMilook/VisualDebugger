//
//  Rotateable.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics
import VisualUtils

public protocol Cloneable {
    func clone() -> Self
}

public protocol StaticRendable: Cloneable {
    // raw bounds
    var contentBounds: CGRect { get }
    
    func render(
        with transform: Matrix2D,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    )
}
