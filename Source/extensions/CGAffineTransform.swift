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
    
    public func debugView(of options: DebugOptions = [], use rect: AffineRect = .unit, image: CGImage? = nil) -> AppView {
        let config = DebugConfig(options: options)
        return getDebugView(in:               config.coordinate,
                            visibleRect:      nil,
                            affineRect:       rect,
                            image:            image,
                            scale:            config.scale,
                            numDivisions:     config.numDivisions,
                            showOrigin:       config.showOrigin)
    }
    
    public func getDebugView(in coordinate:CoordinateSystem.Mode, visibleRect:CGRect? = nil, affineRect:AffineRect = .unit, image: CGImage? = nil, scale:CGFloat = 1.5, numDivisions:Int = 5, showOrigin:Bool = true) -> AppView {
        let t = AffineTransform(rect: affineRect, image: image ?? getTransformImage(), transform: self)
        return t.getDebugView(in: coordinate, visibleRect: visibleRect, scale: scale, numDivisions: numDivisions, showOrigin: showOrigin)
    }
}
