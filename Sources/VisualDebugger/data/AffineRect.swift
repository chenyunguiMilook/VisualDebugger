//
//  AffineRect.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#else
import Cocoa
#endif

public struct AffineRect {
    
    public var v0: CGPoint // top left
    public var v1: CGPoint // top right
    public var v2: CGPoint // bottom right
    public var v3: CGPoint // bottom left
    
    public init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.v0 = CGPoint(x: x,       y: y)
        self.v1 = CGPoint(x: x+width, y: y)
        self.v2 = CGPoint(x: x+width, y: y+height)
        self.v3 = CGPoint(x: x,       y: y+height)
    }
    
    public init(v0: CGPoint, v1: CGPoint, v2: CGPoint, v3: CGPoint) {
        self.v0 = v0
        self.v1 = v1
        self.v2 = v2
        self.v3 = v3
    }
}

extension AffineRect {
    public static let unit: AffineRect = AffineRect(x: 0, y: 0, width: 1, height: 1)
    public var bounds: CGRect { return [v0, v1, v2, v3].bounds }
    public var center: CGPoint { return calculateCenter(v0, v2) }
    public var angle: CGFloat { return calculateAngle(v0, v1) }
    public var width: CGFloat { return calculateDistance(v0, v1) }
    public var height: CGFloat { return calculateDistance(v0, v3) }
}

public func * (rect: AffineRect, t: CGAffineTransform) -> AffineRect {
    let v0 = rect.v0.applying(t)
    let v1 = rect.v1.applying(t)
    let v2 = rect.v2.applying(t)
    let v3 = rect.v3.applying(t)
    return AffineRect(v0: v0, v1: v1, v2: v2, v3: v3)
}

// MARK: - AffineRect

extension AffineRect : Debuggable {
    
    public func debug(in coordinate: CoordinateSystem, color: AppColor?) {
        let rect = self * coordinate.matrix
        let shape = AppBezierPath()
        shape.move(to: rect.v0)
        shape.addLine(to: rect.v1)
        shape.addLine(to: rect.v2)
        shape.addLine(to: rect.v3)
        shape.close()
        
        let color = color ?? coordinate.getNextColor().withAlphaComponent(0.2)
        coordinate.addSublayer(CAShapeLayer(path: shape.cgPath, strokeColor: nil, fillColor: color, lineWidth: 0))
        
        let xPath = AppBezierPath()
        xPath.move(to: rect.v0)
        xPath.addLine(to: rect.v1)
        coordinate.addSublayer(CAShapeLayer(path: xPath.cgPath, strokeColor: .red, fillColor: nil, lineWidth: 1))
        
        let yPath = AppBezierPath()
        yPath.move(to: rect.v0)
        yPath.addLine(to: rect.v3)
        coordinate.addSublayer(CAShapeLayer(path: yPath.cgPath, strokeColor: .green, fillColor: nil, lineWidth: 1))
    }
}
