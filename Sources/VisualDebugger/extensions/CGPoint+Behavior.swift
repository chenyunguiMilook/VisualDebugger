//
//  CGPoint.swift
//  VisualDebugger
//
//  Created by chenyungui on 2025/2/26.
//

import CoreGraphics

extension Array where Element == CGPoint {
    var bounds: CGRect? {
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

extension CGPoint {
    var angle: CGFloat {
        return CGFloat(atan2(Double(self.y), Double(self.x)))
    }

    var length: CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }

    var squareLength: CGFloat {
        return self.x * self.x + self.y * self.y
    }
}

func += (left: inout CGPoint, right: CGPoint) {
    left.x += right.x
    left.y += right.y
}

func -= (left: inout CGPoint, right: CGPoint) {
    left.x -= right.x
    left.y -= right.y
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public prefix func - (point: CGPoint) -> CGPoint {
    return CGPoint(x: -point.x, y: -point.y)
}

func / (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x / right, y: left.y / right)
}

func * (left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
}

func * (left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: left * right.x, y: left * right.y)
}

func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
}

func *= (lhs: inout CGPoint, rhs: CGFloat) {
    lhs.x *= rhs
    lhs.y *= rhs
}

func /= (lhs: inout CGPoint, rhs: CGFloat) {
    lhs.x /= rhs
    lhs.y /= rhs
}

extension Array where Element == CGPoint {
    var gravityCenter: CGPoint {
        var c = CGPoint()
        var area: CGFloat = 0.0
        let p1X: CGFloat = 0.0
        let p1Y: CGFloat = 0.0
        let inv3: CGFloat = 1.0 / 3.0

        for i in stride(from: self.startIndex, to: self.endIndex, by: 1) {
            let p2 = self[i]
            let next = self.index(i, offsetBy: 1)
            let p3 = (next == self.endIndex ? self[self.startIndex] : self[next])

            let e1X = p2.x - p1X
            let e1Y = p2.y - p1Y
            let e2X = p3.x - p1X
            let e2Y = p3.y - p1Y

            let D = (e1X * e2Y - e1Y * e2X)

            let triangleArea = 0.5 * D
            area += triangleArea

            c.x += triangleArea * inv3 * (p1X + p2.x + p3.x)
            c.y += triangleArea * inv3 * (p1Y + p2.y + p3.y)
        }

        c.x *= 1.0 / area
        c.y *= 1.0 / area

        return c
    }
    
    var polyIsCCW: Bool {
        var sum: CGFloat = 0.0
        for i in 0..<count {
            let curt = self[i]
            let next = self[i == count - 1 ? 0 : i + 1]
            sum += (next.x - curt.x) * (next.y + curt.y)
        }
        return sum > 0
    }
}
