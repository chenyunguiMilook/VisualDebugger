//
//  SegmentRenderer.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/3.
//

import CoreGraphics
import VisualUtils

public protocol SegmentRenderer {
    func getBezierPath(start: CGPoint, end: CGPoint) -> AppBezierPath
}
