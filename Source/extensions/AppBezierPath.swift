//
//  NSBezierPath.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

#if os(macOS)
import Foundation
import AppKit


public extension NSBezierPath {
    
    public var cgPath: CGPath {
        let path = CGMutablePath()
        guard self.elementCount > 0 else { return path }
        var points = [NSPoint](repeating: NSPoint.zero, count: 3)
        
        for index in 0..<elementCount {
            let pathType = self.element(at: index, associatedPoints: &points)
            switch pathType {
            case .moveTo:    path.move(to: points[0])
            case .lineTo:    path.addLine(to: points[0])
            case .curveTo:   path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath: path.closeSubpath()
            }
        }
        return path
    }
    
    public func apply(_ t:CGAffineTransform) {
        let transform = AppKit.AffineTransform(m11: t.a, m12: t.b, m21: t.c, m22: t.d, tX: t.tx, tY: t.ty)
        self.transform(using: transform)
    }
    
    public func addLine(to point:CGPoint) {
        self.line(to: point)
    }
    
    public func addCurve(to point:CGPoint, controlPoint1 point1:CGPoint, controlPoint2 point2:CGPoint) {
        self.curve(to: point, controlPoint1: point1, controlPoint2: point2)
    }
    
    private func interpolate(_ p1:CGPoint, _ p2:CGPoint, _ ratio:CGFloat) -> CGPoint {
        return CGPoint(x: p1.x + (p2.x-p1.x) * ratio, y: p1.y + (p2.y-p1.y) * ratio)
    }
    
    public func addQuadCurve(to end:CGPoint, controlPoint:CGPoint) {
        let start = self.currentPoint
        let control1 = interpolate(start, controlPoint, 0.666666)
        let control2 = interpolate(end,   controlPoint, 0.666666)
        self.curve(to: end, controlPoint1: control1, controlPoint2: control2)
    }
    
    public func addArc(withCenter center:CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        self.appendArc(withCenter: center, radius : radius, startAngle : startAngle, endAngle : endAngle, clockwise : clockwise)
    }
}

#endif

// MARK: - BezierPath
#if os(iOS) || os(tvOS)
import UIKit
#else
import Cocoa
#endif

extension AppBezierPath : Debuggable {
    
    public func debug(in coordinate: CoordinateSystem, color: AppColor?) {
        var mutableTransform = coordinate.matrix
        guard let cgPath = self.cgPath.copy(using: &mutableTransform) else { return }
        let shapeLayer = CAShapeLayer(path: cgPath, strokeColor: color ?? coordinate.getNextColor(), fillColor: nil, lineWidth: 1)
            shapeLayer.applyDefaultContentScale()
        coordinate.addSublayer(shapeLayer)
    }
}


