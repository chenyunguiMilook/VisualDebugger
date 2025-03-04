//
//  SegmentRenderer.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics

public protocol SegmentRenderer {
    func getBezierPath(start: CGPoint, end: CGPoint) -> AppBezierPath
}
