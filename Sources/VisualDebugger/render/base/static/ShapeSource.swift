//
//  ShapeSource.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics

// TODO: remove ShapeSource, make protocol is easier to use
public enum ShapeSource {
    case path(AppBezierPath)
    case shape(ShapeType, size: CGSize, anchor: Anchor)
    
    public var path: AppBezierPath {
        switch self {
        case .path(let path):
            path
        case .shape(let shapeType, let size, let anchor):
            shapeType.createPath(size: size, anchor: anchor)
        }
    }
    
    public var bounds: CGRect {
        switch self {
        case .path(let path):
            path.bounds
        case .shape(_, let size, let anchor):
            CGRect(anchor: anchor, center: .zero, size: size)
        }
    }
}

