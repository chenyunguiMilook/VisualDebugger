//
//  Line.swift
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

public final class Line: SegmentDebugger {
    
    public let start: CGPoint
    public let end: CGPoint
    
    public init(
        start: CGPoint,
        end: CGPoint,
        transform: Matrix2D = .identity,
        color: AppColor = .yellow,
        vertexShape: VertexShape = .shape(Circle(radius: 2)),
        edgeShape: EdgeShape = .arrow(Arrow())
    ) {
        self.start = start
        self.end = end
        super.init(transform: transform, color: color, vertexShape: vertexShape, edgeShape: edgeShape)
    }
}
