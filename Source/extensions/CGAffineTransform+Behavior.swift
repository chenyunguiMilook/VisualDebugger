//
//  CGAffineTransform.swift
//  VisualDebugger
//
//  Created by chenyungui on 2018/3/19.
//

import Foundation
import CoreGraphics

extension CGAffineTransform {
    
    func rotated(by angle: CGFloat) -> CGAffineTransform {
        return self * CGAffineTransform(rotationAngle: angle)
    }
    
    func scaledBy(x sx: CGFloat, y sy: CGFloat) -> CGAffineTransform {
        return self * CGAffineTransform(scaleX: sx, y: sy)
    }
    
    func translatedBy(x tx: CGFloat, y ty: CGFloat) -> CGAffineTransform {
        return self * CGAffineTransform(translationX: tx, y: ty)
    }
    
    // mutating
    mutating func rotate(by angle:CGFloat) {
        self = self.rotated(by: angle)
    }
    
    mutating func scaleBy(x:CGFloat, y:CGFloat)  {
        self = self.scaledBy(x: x, y: y)
    }
    
    mutating func translateBy(x:CGFloat, y:CGFloat) {
        self = self.translatedBy(x: x, y: y)
    }
    
    mutating func invert() {
        self = self.inverted()
    }
}

func * (m1: CGAffineTransform, m2: CGAffineTransform) -> CGAffineTransform {
    return m1.concatenating(m2)
}

func * (p:CGPoint, m: CGAffineTransform) -> CGPoint {
    return p.applying(m)
}

func *(lhs: [CGPoint], rhs: CGAffineTransform) -> [CGPoint] {
    return lhs.map{ $0 * rhs }
}

extension CGAffineTransform {
    
    public func getAffineTransform(rect: AffineRect = .unit, image: CGImage? = nil) -> AffineTransform {
        return AffineTransform.init(rect: rect, image: image, transform: self)
    }
}
