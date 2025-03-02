//
//  Rotateable.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics

public protocol StaticRendable {
    var contentBounds: CGRect { get }
    
    func render(
        to location: CGPoint,
        angle: Double,
        in context: CGContext,
        scale: CGFloat,
        contextHeight: Int?
    )
}
