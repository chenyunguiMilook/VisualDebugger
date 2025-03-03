//
//  SegmentRenderer.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics

public protocol SegmentRenderer: Cloneable {
    
    func renderSegment(
        start: CGPoint,
        end: CGPoint,
        in context: CGContext,
        scale: Double,
        contextHeight: Int?
    )
}
