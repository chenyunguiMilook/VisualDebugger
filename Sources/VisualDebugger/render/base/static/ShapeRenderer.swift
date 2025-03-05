//
//  ShapeSource.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/3/2.
//

import CoreGraphics

public protocol ShapeRenderer {
    var radius: Double { get }
    var bounds: CGRect { get }
    func getBezierPath() -> AppBezierPath
}

extension AppBezierPath: ShapeRenderer {
    public var radius: Double {
        let w = self.bounds.width / 2
        let h = self.bounds.height / 2
        return max(w, h)
    }
    public func getBezierPath() -> AppBezierPath {
        self
    }
}
