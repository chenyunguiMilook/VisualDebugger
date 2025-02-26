//
//  CGPoint.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import CoreGraphics

extension Array where Element == CGPoint {
    public var bounds: CGRect? {
        guard !self.isEmpty else { return nil }
        let pnt = self.first!
        var minX = pnt.x
        var minY = pnt.y
        var maxX = pnt.x
        var maxY = pnt.y

        for point in self {
            minX = point.x < minX ? point.x : minX
            minY = point.y < minY ? point.y : minY
            maxX = point.x > maxX ? point.x : maxX
            maxY = point.y > maxY ? point.y : maxY
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

public func += (left: inout CGPoint, right: CGPoint) {
    left.x += right.x
    left.y += right.y
}

public func -= (left: inout CGPoint, right: CGPoint) {
    left.x -= right.x
    left.y -= right.y
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public prefix func - (point: CGPoint) -> CGPoint {
    return CGPoint(x: -point.x, y: -point.y)
}

public func / (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x / right, y: left.y / right)
}

public func * (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
}

public func * (left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: left * right.x, y: left * right.y)
}

public func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
}

public func *= (lhs: inout CGPoint, rhs: CGFloat) {
    lhs.x *= rhs
    lhs.y *= rhs
}

public func /= (lhs: inout CGPoint, rhs: CGFloat) {
    lhs.x /= rhs
    lhs.y /= rhs
}
