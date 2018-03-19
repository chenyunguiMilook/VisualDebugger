//
//  AffineRect.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics

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
