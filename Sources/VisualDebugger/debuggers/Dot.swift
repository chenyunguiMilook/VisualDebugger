//
//  Point.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/5.
//

import CoreGraphics
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public final class Dot: VertexDebugger {
    
    public var position: CGPoint
    
    public init(
        _ position: CGPoint,
        transform: Matrix2D = .identity,
        color: AppColor = .yellow,
        vertexShape: VertexShape = .shape(Circle(radius: 2))
    ) {
        self.position = position
        super.init(transform: transform, color: color, vertexShape: vertexShape)
    }
}
